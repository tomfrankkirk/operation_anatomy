class AddSystemToTopics < ActiveRecord::Migration[5.0]
  def change
    add_reference :topics, :system, foreign_key: true
  end
end
