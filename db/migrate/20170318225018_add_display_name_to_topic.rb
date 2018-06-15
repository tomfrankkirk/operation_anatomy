# frozen_string_literal: true

class AddDisplayNameToTopic < ActiveRecord::Migration[5.0]
  def change
    add_column :topics, :display_name, :string
  end
end
