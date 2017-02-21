class Question < ApplicationRecord
    serialize :possibleSolutions
    belongs_to :topic

    def respond(userResponse)
        if userResponse == self.solution 
            return true
        else 
            return false
        end
    end 

end
