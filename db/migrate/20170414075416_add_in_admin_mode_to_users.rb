# frozen_string_literal: true

class AddInAdminModeToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :inAdminMode, :bool, default: false
  end
end
