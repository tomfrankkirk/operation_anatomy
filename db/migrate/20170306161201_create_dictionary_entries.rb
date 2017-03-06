class CreateDictionaryEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :dictionary_entries do |t|
      t.string :title
      t.string :definition
      t.string :example

      t.timestamps
    end
    
    add_index :dictionary_entries, :title
  end
end
