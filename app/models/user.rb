class User < ApplicationRecord
    serialize :questionIDs, Array

    ScoreRecord = Struct.new(:score, :date)
        
    # Prepare an array of question IDs (selected from topic and level) for the User
    # to respond to. The array will then be stored in the database (as a column on 
    # the User table), IDs can then be retrieved individually by the user as required. 
    # The user will use the IDs to fetch questions directly from the database, they
    # will resond and have their score saved for each question individually. 
    # Whats the point of all this? No state in Rails! The server will not directly keep
    # track of a user's progress through a set of questions, so the user's state must be 
    # stored within the user object (and so in the database table)

    def prepareQuestions(topicID, level)
        self.questionIDs =  Topic.find(topicID).fetchQuestionIDsForLevel(level)
        self.save
    end

    def sendNextQuestionID
        @next = self.questionIDs.pop
        self.save
        return @next
    end
    
    def updateScore(forTopic, forLevel, score)
        scoreRecord = ScoreRecord.new(score, Time.now.strftime("%d/%m/%Y"))
        # check if the hash for this topic already exists
        # if so, dump the new score in there under a numeric hash key
        # this is good because hashes can return nils whereas arrays cannot. 
        if existingTopicHash = self.scoresDictionary[forTopic]
            if forLevel < existingTopicHash.count
                existingTopicHash[forLevel] = scoreRecord
            elsif forLevel == existingTopicHash.count
                existingTopicHash.append(scoreRecord)
            else
                puts "Warning: could not add score for #{self.id}, requested level #{forLevel} and topic #{forTopic}."
                puts "Current length of score array for topic #{forTopic} is #{existingTopicHash.count}."
                puts "Score not recorded."
            end
       else
            # no hash -> this must be level one, so generate new array. 
            self.scoresDictionary[forTopic] = [scoreRecord]
        end
        self.save
    end

    # Get score-date object. Check that the topic hash does actually exist before
    # attempting to access it. If not return nil 
    def getScore(forTopic, forLevel)
        # Check for dodgy inputs. 
        if forLevel <= 0
            puts "Warning: 0 or lower level requested for getScore on topic #{forTopic} user #{self.id} object. Nil returned"
            return nil 
        end

        # Nonnegative inputs - check that the topic hash exists and if so check that the 
        # level has actually been attempted
        if topicHash = self.scoresDictionary[forTopic]
            if forLevel > (topicHash.count - 1)
                return topicHash[forLevel - 1] 
            else
                puts "Warning: too high a level requested for getScore on topic #{forTopic} user #{self.id} object. Nil returned"
                return nil 
            end
        else
            return nil 
        end

    end


end
