class Question < ApplicationRecord
    serialize :possibleSolutions
    belongs_to :topic

end
