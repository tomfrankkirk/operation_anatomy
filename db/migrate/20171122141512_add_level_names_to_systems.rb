class AddLevelNamesToSystems < ActiveRecord::Migration[5.0]
  def change
    add_column :systems, :level_names, :text
  end
end
