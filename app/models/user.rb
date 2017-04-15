class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :feedback_records      
  serialize :questionIDs, Array
   
  # Prepare an array of question IDs (selected from topic and level) for the User
  # to respond to. The array will then be stored in the database (as a column on 
  # the User table), IDs can then be retrieved individually by the user as required. 
  # The user will use the IDs to fetch questions directly from the database, they
  # will resond and have their score saved for each question individually. 
  # Whats the point of all this? No state in Rails! The server will not directly keep
  # track of a user's progress through a set of questions, so the user's state must be 
  # stored within the user object (and so in the database table)

  def prepareQuestions(topicID, level)
      self.questionIDs = Topic.find(topicID).fetchQuestionIDsForLevel(level)
      self.save
  end

  def sendNextQuestionID()
      nextq = self.questionIDs.pop
      self.save
      return nextq
  end

  # A simple integer field that is used to record scores whilst a level is in progress. 
  # The function hasFinishedQuestions() is responsible for reading out this variable, 
  # calculating a score and then wiping it. 

  def incrementCurrentScore()
      self.currentScore = self.currentScore + 1
  end

  def wipeCurrentScore()
      self.currentScore = 0 
  end

  def getCurrentScore()
      return self.currentScore
  end

  # End of level. Read the final score (from currentScore), scale to % terms
  # and then save into the scores dict (using a separate function)

  def hasFinishedQuestions(forTopic, forLevel)
      if forTopic && forLevel
          topic = Topic.find(forTopic)
          score = 100 * (self.currentScore) / (topic.numberOfQuestionsInLevel(forLevel))
          # Check not in revision mode (to save score)
          if !self.revisionMode
            if !(self.updateLevelScore(topic.name, forLevel, score))
                puts "Warning: did not manage to save score"
            end 
          end   
          self.wipeCurrentScore
          self.save
          return true 
      else 
          puts "User.hasFinishedQuestions warning: could not save scores, forTopic and forLevel were passed in as nil"
          return false 
      end
  end

    # SCORE RECORD METHODS

    # Write in level scores to the scoresDictionary. 
    # Generally, forTopic and forLevel are passed in as strings (although they are
    # active record ids, eg "1" instead of 1), so convert level to an int and topic
    # to a string. ScoreRecord is a struct to store a score-date pair. 

    ScoreRecord = Struct.new(:score, :date)
    Threshold = 65

    # Update this to go with proper hashes!
    def updateLevelScore(forTopic, forLevel, score)
        level = forLevel.to_s.to_i
        scoreRecord = ScoreRecord.new(score, Time.now.strftime("%d/%m/%Y"))
        # Check if the hash for this topic already exists
        # If so write the score in using the level as a numeric index into the array
        if existingTopicHash = self.scoresDictionary[forTopic]
            if level <= (existingTopicHash.count)
                existingTopicHash[level - 1].append(scoreRecord)
            elsif level == existingTopicHash.count + 1
                existingTopicHash.append([scoreRecord])
            else
                puts "Warning: could not add score for #{self.id}, requested level #{forLevel} and topic #{forTopic}."
                puts "Current length of score array for topic #{forTopic} is #{existingTopicHash.count}."
                puts "Score not recorded."
                return false
            end
        else
            # No hash: this must be level one for the topic, so generate new array.
            # Add the dummy 100% score record for level 0 in 
            dummy = ScoreRecord.new(score, "NULL")
            self.scoresDictionary[forTopic] = [[dummy], [scoreRecord]]
        end
        return true
    end

    # Get score-date object. Check that the topic hash does actually exist before
    # attempting to access it. If not return nil. Again make sure the inputs are in the right form. 

    def getLevelScore(forTopic, forLevel)
        level = (forLevel.to_s).to_i

        # Check for dodgy inputs. 
        if level <= 0
            puts "Warning: 0 or lower level requested for getScore on topic #{level} user #{self.id} object. Nil returned"
            return nil 
        end

        # Nonnegative inputs - check that the topic hash exists and if so check that the 
        # level has actually been attempted
        if topicHash = self.scoresDictionary[forTopic]
            if level <= (topicHash.count)
                return topicHash[level - 1].max_by { |date, score| score }
            else
                return nil 
            end
        else
            return nil 
        end
    end

    def getLastScore(forTopic, forLevel)
        level = forLevel.to_i
        topicName = Topic.find(forTopic).name 

        if topicHash = self.scoresDictionary[topicName]
            return topicHash[forLevel.to_i - 1].last 
        else 
            return nil 
        end 
    end 

    # Check the highest level questions the user should have access to for a particular topic. 
    # Pass in the topic ID, not the topic name!

    def checkLevelAccess(forTopic)
        # Check what level they have viewed up to first
        maxView = self.getHighestViewedLevel(forTopic)

        # If the most recent score is greater than the threshold, then give access to the next level
        # If not, give access to the level that they are currently working on (and have not yet managed
        # to get above threshold for -> this is simply the count of scores in the topic hash)
        if existingTopicHash = scoresDictionary[forTopic]
            if ( ((existingTopicHash).last).any? { |record| record["score"] >= Threshold } ) 
                return [existingTopicHash.count + 1, maxView].min
            else 
                return [existingTopicHash.count, maxView].min
            end
        else
            # Topic has not previously been attempted, so return 2 (first available level)
            return [maxView, 2].min 
        end 
    
    end

    # LEVEL VIEW METHODS

    # These methods are used to ensure that the user has actually read things before attempting questions. 
    def setLevelViewed(forTopic, forLevel)
        level = forLevel.to_s 
        if existingHash = levelViewsDictionary[forTopic]
            existingHash[level] = true 
        else 
            levelViewsDictionary[forTopic] = {level => true}
        end 
        self.save
    end 

    # Warning: this function has an important side-effect. 

    def getHighestViewedLevel(forTopic)
        # If hash exists all good, otherwise return 0 (user should be allowed to read level 1)
        if existingHash = levelViewsDictionary[forTopic]
            if existingHash == {}
                return 0
            else 
                maxLevel = existingHash.max_by { |level, bool| level.to_i }
                return maxLevel[0].to_i 
            end 
        else 
            return 0
        end 
    end 

end
