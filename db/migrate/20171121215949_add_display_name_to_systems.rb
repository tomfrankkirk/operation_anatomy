class AddDisplayNameToSystems < ActiveRecord::Migration[5.0]
  def change
    add_column :systems, :display_name, :string
  end
end
