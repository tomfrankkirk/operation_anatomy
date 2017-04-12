class AddSolvedFlagToFeedbackRecords < ActiveRecord::Migration[5.0]
  def change
    add_column :feedback_records, :solved, :bool, default: nil 
  end
end
