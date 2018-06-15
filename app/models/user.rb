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

  # Load and shuffle the question IDs for the topic/level name and store them in the user's questionIDs scratch variable. 
  # 
  # @param topicID [Int] the ID for topic 
  # @param levelName [String] the short level name within the topic
  # @return [None]
  def prepareQuestions(topicID, levelName)
    self.currentScore = 0
    self.questionIDs = Topic.find(topicID).fetchQuestionIDsForLevel(levelName)
    self.save
  end

  # Pop a question ID off the user's questionID. 
  # 
  # @return [Int] a question ID. 
  def sendNextQuestionID
    nextq = questionIDs.pop
    self.save
    return nextq
  end

  # Increment the users score for the current set of questions 
  def incrementCurrentScore
    self.currentScore = currentScore + 1
  end

  # Reset user's current score 
  def wipeCurrentScore
    self.currentScore = 0
  end

  # Return user's current score 
  def getCurrentScore
    return currentScore
  end

  # At the end of a level, convert the user's current score to a percentage and save into their score record. 
  # 
  # @param topicID [Int] the ID of the topic for which questions were answered
  # @param levelName [String] the name of the level finished. 
  # @return [Bool] to indicate success or failure 
  def hasFinishedQuestions(topicID, levelName)
    if topicID && levelName

      # Convert score to percentage
      topic = Topic.find(topicID)
      score = (100 * currentScore.to_f / topic.numberOfQuestionsInLevel(levelName)).round

      # If not in revision mode, save
      unless revisionMode
        unless updateLevelScore(topicID, levelName, score)
          puts 'Warning: did not manage to save score'
        end
      end

      # Reset and save
      self.wipeCurrentScore
      self.save
      return true

    else
      puts 'User#hasFinishedQuestions error: nil topicID and levelName passed'
      return false
    end
  end

  # Score methods --------------------------------------------------------------

  # Write in level scores to the scoresDictionary.
  # Generally, forTopic and forLevel are passed in as strings (although they are
  # active record ids, eg "1" instead of 1), so convert level to an int and topic
  # to a string. ScoreRecord is a struct to store a score-date pair.

  # Update the score record for a particular topic and level. 
  # 
  # @param topicID [Int] the topic ID 
  # @param levelName [String] short level name 
  # @param score [Int] score in percent 
  # @return [Bool] to indicate success 
  def updateLevelScore(topicID, levelName, score)

    # Load topic and level number, prepare score record object 
    topic = Topic.find(topicID)
    levelNumber = topic.levelNumber(levelName)
    scoreRecord = ScoreRecord.new(score, Time.now.strftime('%d/%m/%Y'))

    # Check for an existing score hash for this topic, which should exist. 
    # Is the new score greater than existing? Overwrite if so.
    if existingTopicHash = scoresDictionary[topic.shortName]
      if levelHash = existingTopicHash[levelName]
        existingTopicHash[levelName] = scoreRecord unless levelHash[:score] >= score

      # No existing score for this level, so append the new score.
      else
        existingTopicHash[levelName] = scoreRecord
      end
      return true 

      # If we did not find an existing hash for this topic then error. 
    else 
      puts 'User#updateLevelScore error: could not find a hash for this topic'
      return false
    end 

  end

  # Get score for level and topic. Return nil if it does not exist 
  # 
  # @param topicID [Int] topic ID 
  # @param levelName [String] short level name 
  # @return [Int?] score, or nil if it does not exist. 
  def getLevelScore(topicID, levelName)
    topic = Topic.find(topicID)
    levelNumber = topic.levelNumber(levelName)

    # Check for dodgy inputs.
    if levelNumber < 0
      puts "Warning: 0 or lower level requested for getScore on topic #{topic.shortName} user #{id} object. Nil returned"
      return nil
    end

    # Check the level has been attempted, return score if so 
    if topicHash = scoresDictionary[topic.shortName]
      if record = topicHash[levelName]
        return record[:score]
      end
    end

    # Not attempted
    return nil
  end

  # Deprecated 
  # def getLastScore(topicID, levelName)
  #   topic = Topic.find(topicID)

  #   if topicHash = scoresDictionary[topic.shortName]
  #     return topicHash[levelName]
  #   else
  #     return nil
  #   end
  # end

  # Return the highest level for which the threshold score has been reached. 
  # Return 0 if the topic has not yet been attempted. 
  # 
  # @param topicID [Int] topic ID 
  # @return [Int] the level, 0 if not topic not attempted. 
  def getHighestLevelPassed(topicID)
    topic = Topic.find(ID)

    # If scores exist for the topic, pick the max that is above threshold. Otherwise return 0
    if existingTopicHash = scoresDictionary[topic.shortName]
      maxLevelScored = existingTopicHash.max_by do |l, r| 
        r['score'] >= THRESHOLD ? topic.levelNumber(l) : 0
      end
      return maxLevelScored

    else
      return 0
    end 

  end 

  # Check the highest level questions the user should have access to for a particular topic. This is defined as the min of (the highest viewed level) and (level for which they have reached the score threshold + 1)
  # 
  # @param topicID [Int] the topic ID 
  # @return [Int] level number (0-indexed)
  def checkLevelAccess(topicID)

    topic = Topic.find(topicID)
    maxView = getHighestViewedLevel(topicID)

    if existingTopicHash = scoresDictionary[topic.shortName]
      # Find the highest level for which a score has been recorded.

      maxLevelScored = topic.levelNumber(maxLevelScored[0])
      return [maxLevelScored + 1, maxView].min

    else
      return maxView
    end
  end

  # Initialise the level 0 score for the user when first attempting a topic. 
  # As level 0 does not have any questions, a dummy record is created to grant users access to level 1. 
  # 
  # @param topicID [Int] topic ID to initialise the dummy for 
  def initialiseDummyScoreForTopic(topicID)
    topic = Topic.find(topicID)
    dummy = ScoreRecord.new(100, 'NULL')

    # Initialise the score hash for this topic 
    scoresDictionary[topic.shortName] = { 'introduction' => dummy }
    self.save
  end

  # Level methods --------------------------------------------------------------

  # Record the levels viewed for each topic.
  # If no questions have been attempted for the topic then also initialise 
  # the score record for that topic (setting a dummy score for introduction)
  # 
  # @param topicID [Int] topic ID 
  # @param levelName [String] short level name 
  def setLevelViewed(topicID, levelName)
    topic = Topic.find(topicID)
    
    if existingHash = levelViewsDictionary[topic.shortName]
      existingHash[levelName] = true

      # Topic has not been attempted -> initialse dummy 
    else
      levelViewsDictionary[topic.shortName] = { levelName => true }
      initialiseDummyScoreForTopic(topicID)
    end

    self.save
  end

  # Get highest level viewed for topic 
  # 
  # @param topicID [Int] topic ID 
  # @return [Int] level number 
  def getHighestViewedLevel(topicID)
    topic = Topic.find(topicID)

    # If a view hash exists, use that. 
    maxLevel = if existingHash = levelViewsDictionary[topic.shortName]

      # View hash may exist but simply be empty 
      level = if existingHash.empty?
        0 

        # If exists, max of viewed levels. 
      else
        existingHash.max_by do |levelName, bool| 
          bool ? topic.levelNumber(levelName) : 0
        end 
      end

      # If not then return 0 (topic never viewed)
    else
      0 
    end
    return maxLevel

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
