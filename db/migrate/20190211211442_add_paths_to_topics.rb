class AddPathsToTopics < ActiveRecord::Migration[5.0]
  def change
    add_column :topics, :paths, :jsonb
  end
end
