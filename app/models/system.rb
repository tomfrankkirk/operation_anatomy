# frozen_string_literal: true

class System < ApplicationRecord
  has_many :topics
  serialize :level_names, Array

  # Return short system name (string)
  def shortName
    name.split[0].downcase
  end

end