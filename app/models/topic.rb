# frozen_string_literal: true

class Topic < ApplicationRecord
  serialize :level_names, Array
  belongs_to :system
  has_many :questions, dependent: :destroy


  def shortName
    splits = name.downcase.split
    return splits[1] if splits[0] == 'the'
    splits[0]
  end

  def shortLevelNames
    sys = System.find(system_id)
    sys.shortLevelNames
  end

  
  # Yard demo here
  # @param forLevel [Int] the number of the level
  # @return [String] the level name. 
  def levelName(forLevel)
    shortLevelNames[forLevel]
  end

  # Another demo here
  # @param [String] 
  # @return [Int] some return 
  def levelNumber(forName)
    shortLevelNames.find_index(forName)
  end

  # Method to fetch shuffled array for all questions of a certain level within a topic.
  # The IDs are then passed to a User, they will then fetch questions directly from
  # the database by using each id as a key.

  def fetchQuestionIDsForLevel(levelName)

    # NB indexing adjustment here - questions start at level 2 (1 is intro)
    level = levelNumber(levelName) + 1
    questionObjects = questions.where('level = ?', level)
    questionIDs = []
    # extract each question ID.
    questionObjects.each do |q|
      questionIDs << q.id
    end
    questionIDs.shuffle
  end

  def numberOfQuestionsInLevel(levelName)
    qs = fetchQuestionIDsForLevel(levelName).count
  end

  def numberOfLevels
    names = shortLevelNames
    names.count
  end

  def levelNames
    System.find(system_id).level_names
  end
end
