class User < ApplicationRecord
   # Include default devise modules. Others available are:
   # :confirmable, :lockable, :timeoutable and :omniauthable
   devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

   has_many :feedback_records      
   serialize :questionIDs, Array

   ScoreRecord = Struct.new(:score, :date)
   Threshold = 65
      
   # Prepare an array of question IDs (selected from topic and level) for the User
   # to respond to. The array will then be stored in the database (as a column on 
   # the User table), IDs can then be retrieved individually by the user as required. 
   # The user will use the IDs to fetch questions directly from the database, they
   # will resond and have their score saved for each question individually. 
   # Whats the point of all this? No state in Rails! The server will not directly keep
   # track of a user's progress through a set of questions, so the user's state must be 
   # stored within the user object (and so in the database table)

   def prepareQuestions(topicID, levelName)
      self.currentScore = 0 
      self.questionIDs = Topic.find(topicID).fetchQuestionIDsForLevel(levelName)
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

  def hasFinishedQuestions(topicID, levelName)
      
      if topicID && levelName
          topic = Topic.find(topicID)
   
          score = (100 * (self.currentScore.to_f) / (topic.numberOfQuestionsInLevel(levelName))).round 
          # Check not in revision mode (to save score)
          if !self.revisionMode
            if !(self.updateLevelScore(topicID, levelName, score))
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

   # Update this to go with proper hashes!
   def updateLevelScore(topicID, levelName, score)
      
      topic = Topic.find(topicID)
      levelNumber = topic.levelNumber(levelName)
      scoreRecord = ScoreRecord.new(score, Time.now.strftime("%d/%m/%Y"))
      
      # Check if the hash for this topic already exists
      # If so write the score in using the level as a numeric index into the array
      if existingTopicHash = self.scoresDictionary[topic.shortName]

         # Is the new score greater than existing? Overwrite if so. 
         if levelHash = existingTopicHash[levelName]
            existingTopicHash[levelName] = scoreRecord unless levelHash[:score] >= score 
               
         # No existing score for this level, so append the new score. 
         else 
            existingTopicHash[levelName] = scoreRecord
         end 

      else
         # No hash: this must be level one for the topic, so generate new array.
         # Add the dummy 100% score record for level 0 in 
         #FIXME: hardcoded introduction as the level 0 name here. 
         dummy = ScoreRecord.new(score, "NULL")
         self.scoresDictionary[topic.shortName] = { "introduction" => dummy }
         self.scoresDictionary[topic.shortName][levelName] = scoreRecord 
      end
      return true
   end

    # Get score-date object. Check that the topic hash does actually exist before
    # attempting to access it. If not return nil. Again make sure the inputs are in the right form. 

   def getLevelScore(topicID, levelName)
      topic = Topic.find(topicID)
      levelNumber = topic.levelNumber(levelName)
      
      # Check for dodgy inputs. 
      if levelNumber < 0
         puts "Warning: 0 or lower level requested for getScore on topic #{topic.shortName} user #{self.id} object. Nil returned"
         return nil 
      end

      # Nonnegative inputs - check that the topic hash exists and if so check that the 
      # level has actually been attempted
      if (topicHash = self.scoresDictionary[topic.shortName])
         if (record = topicHash[levelName])  
            return record[:score]
         end 
      end 
      return nil 

   end

   def getLastScore(topicID, levelName)
      topic = Topic.find(topicID)

      if topicHash = self.scoresDictionary[topic.shortName]
         return topicHash[levelName]
      else 
         return nil 
      end 
   end 

    # Check the highest level questions the user should have access to for a particular topic. 

   def checkLevelAccess(topicID)
      # Check what level they have viewed up to first
      topic = Topic.find(topicID)
      maxView = self.getHighestViewedLevel(topicID)

      if existingTopicHash = scoresDictionary[topic.shortName]  
         # Find the highest level for which a score has been recorded. 
         maxLevelScored = existingTopicHash.max_by { |l,r| topic.levelNumber(l) if r["score"] >= Threshold }
         maxLevelScored = topic.levelNumber(maxLevelScored[0]) 
         return [maxLevelScored + 1, maxView].min

      else
         # Topic has not previously been attempted, so return 2 (first available level)
         return [maxView, 2].min 
      end 
   
   end

   # LEVEL VIEW METHODS

   # These methods are used to ensure that the user has actually read things before attempting questions. 
   def setLevelViewed(topicID, levelName)
      topic = Topic.find(topicID)

      if existingHash = levelViewsDictionary[topic.shortName]
         existingHash[levelName] = true 
      else 
         levelViewsDictionary[topic.shortName] = {levelName => true}
      end 
      self.save
   end 

   # Warning: this function has an important side-effect. ??
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

   # TODO: these methods need updating with the new hash naming convention. 

   # def softResetLevelViews
   #    self.levelViewsDictionary = {}
   #    Topic.all.each do |t|
   #       t.numberOfLevels.times do |l|
   #          if self.getLevelScore(t.name, l + 1) 
   #             if (self.getLevelScore(t.name, l + 1))["score"] >= Threshold
   #                puts "Setting level viewed for #{t.name}, level #{l+1}"
   #                self.setLevelViewed(t.name, l + 1)
   #             end 
   #          end 
   #       end 
   #    end
   # end 

   # def hardResetLevelViews
   #    self.levelViewsDictionary = {}
   # end 

   def toggleRevisionMode 
      self.revisionMode = !self.revisionMode 
      self.save      
   end 

   def toggleAdminMode 
      if self.isAdmin
         self.inAdminMode = !self.inAdminMode 
      end 
      self.save 
   end 

   private 

   # def preprocessLevelArgument(level, topic)
   #    if level.is_a? Numeric 
   #       level = topic.getLevelName(level) 
   #    end 
   #    return level 
   # end 
   
end