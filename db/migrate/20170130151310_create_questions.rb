class CreateQuestions < ActiveRecord::Migration[5.0]

  def change
    create_table :questions do |t|
      t.column :number, :integer
      t.column :level, :integer
      t.column :body, :string
      t.column :solution, :string
      t.column :possibleSolutions, :string
      t.belongs_to :topic, index: true
      t.timestamps
    end

  end

end
