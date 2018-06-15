# frozen_string_literal: true

class DropSolutionsFromQuestions < ActiveRecord::Migration[5.0]
  def change
    remove_column :questions, :solution
  end
end
