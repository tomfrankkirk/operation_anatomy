# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Users can submit feedback that is associated to their account.
  # QuestionIDs (a scratch variable) are stored as a serialized array
  has_many :feedback_records
  serialize :questionIDs, Array

  # Struct definition for storing the score and date of every attempt at a set of questions (within a larger hash)
  ScoreRecord = Struct.new(:score, :date)

  # Score threshold for passing from one level to the next.
  THRESHOLD = 65

  # Question methods -----------------------------------------------------------

  # Load and shuffle the question IDs for the topic/level name and store them in the user's questionIDs scratch variable. 
  # 
  # @param topicID [Int] the ID for topic 
  # @param level [Int] level number 
  # @return [None]
  def prepareQuestions(topicID, level)
    self.currentScore = 0
    self.questionIDs = Topic.find(topicID).fetchQuestionIDsForLevel(level)
    self.save
  end

  # Pop a question ID off the user's questionID. 
  # 
  # @return [Int] a question ID. 
  def sendQuestion
    nextq = questionIDs.pop
    self.save
    return nextq
  end

  # At the end of a level, convert the user's current score to a percentage and save into their score record. 
  # 
  # @param topicID [Int] the ID of the topic for which questions were answered
  # @param level [Int] level number 
  # @return [Bool] to indicate success or failure 
  def hasFinishedQuestions(topicID, level)
    if topicID && level

      # Convert score to percentage
      topic = Topic.find(topicID)
      score = (100 * currentScore.to_f / topic.numberOfQuestionsInLevel(level)).round

      # If not in revision mode, save
      unless revisionMode
        unless updateLevelScore(topicID, level, score)
          return false 
        end
      end

      # Reset and save
      self.currentScore = 0 
      self.save
      return true

    else
      puts 'User#hasFinishedQuestions error: nil topicID and level passed'
      return false
    end
  end

  # Score methods --------------------------------------------------------------

  # Increment the users score for the current set of questions 
  def incrementCurrentScore
    self.currentScore = currentScore + 1
  end

  # Return user's current score 
  def getCurrentScore
    return currentScore
  end

  # Update the score record for a particular topic and level. 
  # Scores are recorded in the dict with a short level name string
  # as the key (not number)
  # 
  # @param topicID [Int] the topic ID 
  # @param level [Int] level number 
  # @param score [Int] score in percent 
  # @return [Bool] to indicate success 
  def setScore(topicID, level, score)

    # Load topic and level number, prepare score record object 
    topic = Topic.find(topicID)
    scoreRecord = ScoreRecord.new(score, Time.now.strftime('%d/%m/%Y'))
    
    # Check for an existing score hash for this topic, which should exist. 
    # Is the new score greater than existing? Overwrite if so.
    if topicScores = scoresDictionary[topic.shortName]

      if existing = topicScores[level]
        topicScores[level] = scoreRecord unless existing[:score] >= score
      # No existing score for this level, so append the new score.
      else
        raise "Level should be length of existing score array" unless topicScores.count == level
        topicScores[level] = scoreRecord
      end
      return true 

      # If we did not find an existing hash for this topic then error. 
    else 
      puts 'User#updateLevelScore error: could not find a hash for this topic'
      return false
    end
  end

  # Get score for level and topic. Return 0 if never attempted. 
  # 
  # @param topicID [Int] topic ID 
  # @param level [Int] level number 
  # @return [Int] score
  def getScore(topicID, levelNumber)
    topic = Topic.find(topicID)

    # Check the level has been attempted, return score if so 
    if topicScores = scoresDictionary[topic.shortName]
      if record = topicScores[levelNumber]
        return record["score"]
      end
    end

    return 0
  end

  # Return the highest level for which the threshold score has been reached. 
  # Return -1 if the topic has not yet been attempted. 
  # 
  # @param topicID [Int] topic ID 
  # @return [Int] the level, -1 if not topic not attempted. 
  def highestPassedLevel(topicID)
    topic = Topic.find(topicID)

    # If scores exist for the topic, pick the max that is above threshold
    if topicScores = scoresDictionary[topic.shortName]
      scores = topicScores.filter { |s| s["score"] >= THRESHOLD }
      return scores.count - 1
    end 

    # Topic never attempted, return -1 
    return -1 

  end 

  # Initialise the level 0 score for the user when first attempting a topic. 
  # As level 0 does not have any questions, a dummy record is created to grant users access to level 1. 
  # 
  # @param topicID [Int] topic ID to initialise the dummy for 
  def initialiseScoreForTopic(topicID)
    topic = Topic.find(topicID)
    dummy = ScoreRecord.new(100, 'NULL')

    # Initialise the score hash for this topic 
    scoresDictionary[topic.shortName] = [dummy]
    self.save
  end
  
  # Level view methods --------------------------------------------------------

  # Record the levels viewed for each topic.
  # If no questions have been attempted for the topic then also initialise 
  # the score record for that topic (setting a dummy score for introduction)
  # 
  # @param topicID [Int] topic ID 
  # @param level [Int] level number 
  def setLevelViewed(topicID, levelNumber)
    topic = Topic.find(topicID)
    
    if existing = levelViewsDictionary[topic.shortName] 
      levelViewsDictionary[topic.shortName] = levelNumber unless existing > levelNumber

    # Topic has not been attempted -> initialse the hash for this topic
    else
      levelViewsDictionary[topic.shortName] = levelNumber
      initialiseScoreForTopic(topicID)
    end

    self.save
  end

  # Get highest level viewed for topic. Return -1 for never viewed. 
  # 
  # @param topicID [Int] topic ID 
  # @return [Int] level number 
  def highestViewedLevel(topicID)
    topic = Topic.find(topicID)

    # If a view hash exists, use that. 
    if highest = levelViewsDictionary[topic.shortName]        
      return highest
    end 

    # If topic never viewed return -1 
    return -1

  end

  # Other methods -------------------------------------------------------------

  # Check the highest level questions the user should have access to for a particular topic.
  # 
  # @param topicID [Int] the topic ID 
  # @return [Int] level number (0-indexed)
  def levelAccess(topicID)
    maxView = highestViewedLevel(topicID)
    maxLevelScored = highestPassedLevel(topicID)
    maxView >= maxLevelScored ? maxLevelScored + 1 : maxLevelScored
  end

  # Flip the user's current revision state 
  def toggleRevisionMode
    self.revisionMode = !revisionMode
    self.save
  end

  # If the user is an admin, flip their admin state. 
  def toggleAdminMode
    self.inAdminMode = !inAdminMode if isAdmin
    self.save
  end

end
