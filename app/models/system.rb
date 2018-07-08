# frozen_string_literal: true

class System < ApplicationRecord
  has_many :topics
  serialize :level_names, Array

  # Deprecated
  # def shortNameForLevel(levelNumber)
  #   long = level_names[k]
  #   long.split[0]
  # end

  # Return all short level names. Drop leading "the" if present
  # 
  # @return [[String]]
  def shortLevelNames
    longs = level_names
    longs.map { |s| 
      down = s.downcase.split 
      down[0] == 'the' ? down[1] : down[0]
    }
  end

  # Return short system name (string)
  def shortName
    name.split[0].downcase
  end

end