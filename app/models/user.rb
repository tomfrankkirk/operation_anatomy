class User < ApplicationRecord
    serialize :questionIDs, Array
    serialize :scoresForQuestions, Hash
 #   serialize :accessDates

    # Prepare an array of question IDs (selected from topic and level) for the User
    # to respond to. The array will then be stored in the database (as a column on 
    # the User table), IDs can then be retrieved individually by the user as required. 
    # The user will use the IDs to fetch questions directly from the database, they
    # will resond and have their score saved for each question individually. 
    # Whats the point of all this? No state in Rails! The server will not directly keep
    # track of a user's progress through a set of questions, so the user's state must be 
    # stored within the user object (and so in the database table)

    def prepareQuestionsForUserResponse(topicID, level)
        self.questionIDs =  Topic.find(topicID).fetchQuestionIDsForLevel(level)
        self.save
    end

end
