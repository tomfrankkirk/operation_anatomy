class AddLevelViewsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :levelViewsDictionary, :jsonb, default: {}
  end
end
