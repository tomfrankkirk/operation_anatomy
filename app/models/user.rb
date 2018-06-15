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

  # When attempting a set of questions, their IDs will be loaded from the DB, shuffled and then stored in a scratch variable belonging to the user object (questionIDs). The IDs are then popped off one at a time and sent to the user.
  def prepareQuestions(topicID, levelName)
    self.currentScore = 0
    self.questionIDs = Topic.find(topicID).fetchQuestionIDsForLevel(levelName)
    save
  end

  def sendNextQuestionID
    nextq = questionIDs.pop
    save
    nextq
  end

  # A simple integer field that is used to record scores whilst a level is in progress.
  # The function hasFinishedQuestions() is responsible for reading out this variable,
  # calculating a score and then wiping it.

  def incrementCurrentScore
    self.currentScore = currentScore + 1
  end

  def wipeCurrentScore
    self.currentScore = 0
  end

  def getCurrentScore
    currentScore
  end

  # End of level. Read the final score (from currentScore), scale to % terms
  # and then save into the scores dict (using a separate function)

  def hasFinishedQuestions(topicID, levelName)
    if topicID && levelName
      topic = Topic.find(topicID)

      score = (100 * currentScore.to_f / topic.numberOfQuestionsInLevel(levelName)).round
      # Check not in revision mode (to save score)
      unless revisionMode
        unless updateLevelScore(topicID, levelName, score)
          puts 'Warning: did not manage to save score'
        end
      end
      wipeCurrentScore
      save
      true
    else
      puts 'User.hasFinishedQuestions warning: could not save scores, forTopic and forLevel were passed in as nil'
      false
    end
  end

  # SCORE RECORD METHODS

  # Write in level scores to the scoresDictionary.
  # Generally, forTopic and forLevel are passed in as strings (although they are
  # active record ids, eg "1" instead of 1), so convert level to an int and topic
  # to a string. ScoreRecord is a struct to store a score-date pair.

  # Update this to go with proper hashes!
  def updateLevelScore(topicID, levelName, score)
    topic = Topic.find(topicID)
    levelNumber = topic.levelNumber(levelName)
    scoreRecord = ScoreRecord.new(score, Time.now.strftime('%d/%m/%Y'))
    existingTopicHash = scoresDictionary[topic.shortName]
    # Is the new score greater than existing? Overwrite if so.
    if levelHash = existingTopicHash[levelName]
      existingTopicHash[levelName] = scoreRecord unless levelHash[:score] >= score

    # No existing score for this level, so append the new score.
    else
      existingTopicHash[levelName] = scoreRecord
    end

    true
  end

  # Get score-date object. Check that the topic hash does actually exist before
  # attempting to access it. If not return nil. Again make sure the inputs are in the right form.

  def getLevelScore(topicID, levelName)
    topic = Topic.find(topicID)
    levelNumber = topic.levelNumber(levelName)

    # Check for dodgy inputs.
    if levelNumber < 0
      puts "Warning: 0 or lower level requested for getScore on topic #{topic.shortName} user #{id} object. Nil returned"
      return nil
    end

    # Nonnegative inputs - check that the topic hash exists and if so check that the
    # level has actually been attempted
    if (topicHash = scoresDictionary[topic.shortName])
      if (record = topicHash[levelName])
        return record[:score]
      end
    end
    nil
  end

  def getLastScore(topicID, levelName)
    topic = Topic.find(topicID)

    if topicHash = scoresDictionary[topic.shortName]
      return topicHash[levelName]
    else
      return nil
    end
  end

  # Check the highest level questions the user should have access to for a particular topic.
  def checkLevelAccess(topicID)
    # Check what level they have viewed up to first
    topic = Topic.find(topicID)
    maxView = getHighestViewedLevel(topicID)

    if existingTopicHash = scoresDictionary[topic.shortName]
      # Find the highest level for which a score has been recorded.
      maxLevelScored = existingTopicHash.max_by do |l, r|
        if r['score'] >= Threshold
                                  then topic.levelNumber(l) else 0 end
      end
      maxLevelScored = topic.levelNumber(maxLevelScored[0])
      return [maxLevelScored + 1, maxView].min

    else
      return maxView
    end
  end

  # No hash: this must be level one for the topic, so generate new array.
  def initialiseDummyScoreForTopic(topicID)
    topic = Topic.find(topicID)
    dummy = ScoreRecord.new(100, 'NULL')
    scoresDictionary[topic.shortName] = { 'introduction' => dummy }
    save
  end

  # LEVEL VIEW METHODS

  # These methods are used to ensure that the user has actually read things before attempting questions.
  # BIG WARNING: if the topic has never been attempted then this function initialises the dummy score that grants access to level 2 once the introduction has been viewed.
  def setLevelViewed(topicID, levelName)
    topic = Topic.find(topicID)

    if existingHash = levelViewsDictionary[topic.shortName]
      existingHash[levelName] = true
    else
      levelViewsDictionary[topic.shortName] = { levelName => true }
    end
    # Topic has not previously been attempted. Intialise the dummy score whilst we're here.
    initialiseDummyScoreForTopic(topicID)
    save
  end

  def getHighestViewedLevel(topicID)
    # If hash exists all good, otherwise return 0 (user should be allowed to read level 1)
    topic = Topic.find(topicID)
    if existingHash = levelViewsDictionary[topic.shortName]
      if existingHash == {}
        return 0
      else
        maxLevel = existingHash.max_by { |levelName, bool| topic.levelNumber(levelName) if bool }
        return topic.levelNumber(maxLevel[0])
      end
    else
      return 0
    end
  end

  def toggleRevisionMode
    self.revisionMode = !revisionMode
    save
  end

  def toggleAdminMode
    self.inAdminMode = !inAdminMode if isAdmin
    save
  end
end
