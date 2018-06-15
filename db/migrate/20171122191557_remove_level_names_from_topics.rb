# frozen_string_literal: true

class RemoveLevelNamesFromTopics < ActiveRecord::Migration[5.0]
  def change
    remove_column :topics, :level_names, :text
  end
end
