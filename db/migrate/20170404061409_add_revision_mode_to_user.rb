# frozen_string_literal: true

class AddRevisionModeToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :revisionMode, :bool, default: false
  end
end
