class RemoveLevelNamesFromSystems < ActiveRecord::Migration[5.0]
  def change
    remove_column :systems, :level_names
    add_column  :topics, :level_names, :text
  end
end
