class Topic < ApplicationRecord
    has_many :questions, dependent: :destroy

    # Method to fetch shuffled array for all questions of a certain level within a topic. 
    # The IDs are then passed to a User, they will then fetch questions directly from 
    # the database by using each id as a key. 

    def fetchQuestionIDsForLevel(level)
        # fetch all questions for the level
        questionObjects = self.questions.where("level = ?", level)
        questionIDs = []
        # extract each question ID. 
        questionObjects.each do |q|
            questionIDs << q.id
        end
        questionIDs.shuffle
    end

    def numberOfQuestionsInLevel(level)
        return (self.questions.where("level = ?", level)).count
    end 

    def numberOfLevels
        self.questions.maximum("level")
    end

    def sayHello()
        puts sayHello
    end
    
end
