# frozen_string_literal: true

class Topic < ApplicationRecord
  serialize :level_names, Array
  belongs_to :system
  has_many :questions, dependent: :destroy

  # Return the short topic name, one word each, dropping "the" where necessary
  # 
  # @return [String] topic short name
  # def shortName
  #   splits = name.downcase.split
  #   return splits[1] if splits[0] == 'the'
  #   splits[0]
  # end
  def shortName
    self.short_name
  end 

  def levelNames 
    self.level_names.map { |n| n.capitalize }
  end 

  # # Convert level number to short level name 
  # # 
  # # @param forLevel [Int]
  # def levelName(forLevel)
  #   level_names[forLevel]
  # end

  # # Convert between level name and number 
  # # 
  # # @param forName [String]
  # def levelNumber(forName)
  #   shortLevelNames.find_index(forName)
  # end

  # Load and shuffle the questions for the given level.
  # 
  # @param levelName [String] level name of questions (not number)
  # @return questionIDs [[Int]] array of shuffled question IDs 
  def fetchQuestionIDsForLevel(level)
    questionObjects = questions.where('level = ?', level)
    questionIDs = questionObjects.map { |q| q.id }
    questionIDs.shuffle
  end

  # Count the questions in a given level 
  # 
  # @param levelName [String] the short name of the level 
  def numberOfQuestionsInLevel(level)
    qs = fetchQuestionIDsForLevel(level).count
  end

  def numberOfLevels
    self.level_names.count 
  end 

end
