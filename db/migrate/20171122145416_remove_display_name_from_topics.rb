class RemoveDisplayNameFromTopics < ActiveRecord::Migration[5.0]
  def change
   remove_column :topics, :display_name, :string
  end
end
