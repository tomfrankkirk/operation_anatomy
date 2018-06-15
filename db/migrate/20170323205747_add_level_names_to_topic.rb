# frozen_string_literal: true

class AddLevelNamesToTopic < ActiveRecord::Migration[5.0]
  def change
    add_column :topics, :level_names, :text
  end
end
