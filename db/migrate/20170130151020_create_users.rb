class CreateUsers < ActiveRecord::Migration[5.0]
  
  def change

    create_table :users do |t|
      t.column :name, :string
      t.column :email, :string
      t.column :password, :string

      t.column :questionIDs, :text
      t.column :scoresDictionary, :jsonb, default: {}
      t.timestamps
    end

    add_index :users, :scoresDictionary
  end
end
