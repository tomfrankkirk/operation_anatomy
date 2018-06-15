# frozen_string_literal: true

class System < ApplicationRecord
  has_many :topics
  serialize :level_names, Array

  def shortNameForLevel(_k)
    long = level_names
    long.split[0]
  end

  def shortLevelNames
    longs = level_names
    longs.map { |s| s.split[0].downcase }
  end

  def shortName
    name.split[0].downcase
  end
end
