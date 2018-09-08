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

  # Topic level names are common to a system, hence this method is actually
  # called on the parent system. 
  # 
  # @return [[String]]
  def shortLevelNames
    sys = System.find(system_id)
    sys.shortLevelNames
  end

  # Convert level number to short level name 
  # 
  # @param forLevel [Int]
  def levelName(forLevel)
    shortLevelNames[forLevel]
  end

  # Convert between level name and number 
  # 
  # @param forName [String]
  def levelNumber(forName)
    shortLevelNames.find_index(forName)
  end

  # Load and shuffle the questions for the given level.
  # 
  # @param levelName [String] level name of questions (not number)
  # @return questionIDs [[Int]] array of shuffled question IDs 
  def fetchQuestionIDsForLevel(levelName)

    # NB indexing adjustment here - questions start at level 2 (1 is intro)
    level = levelNumber(levelName) + 1
    questionObjects = questions.where('level = ?', level)
    questionIDs = questionObjects.map { |q| q.id }
    questionIDs.shuffle
  end

  # Count the questions in a given level 
  # 
  # @param levelName [String] the short name of the level 
  def numberOfQuestionsInLevel(levelName)
    qs = fetchQuestionIDsForLevel(levelName).count
  end

  # Number of levels in topic 
  def numberOfLevels
    names = shortLevelNames
    names.count
  end

  # Level names are common to all topics within a system so they are stored
  # at that level. 
  # 
  # @return [[String]]
  def levelNames
    System.find(system_id).level_names
  end

end
