class CreateFeedbackRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :feedback_records do |t|
      t.string  :tone
      t.string  :comment 
      
      t.belongs_to :user, index: true
      t.timestamps
    end
  end
end
