class Question < ApplicationRecord
    serialize :possibleSolutions
    belongs_to :topic

    def respond(userResponse)
        if userResponse == self.possibleSolutions[0] 
            return true
        else 
            return false
        end
    end 

    def shuffledSolutions
        return self.possibleSolutions.shuffle 
    end 

    def qID
        topicName = Topic.find(topic_id).name
        return topicName + "L#{self.level}Q#{self.number}"
    end

    def solution 
        return self.possibleSolutions.first 
    end 

end
