class AddShortNameToTopics < ActiveRecord::Migration[5.0]
  def change
    add_column :topics, :short_name, :string
    add_index :topics, :short_name 
  end
end
