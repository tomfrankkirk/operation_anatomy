require 'test_helper'

class TopicTest < ActiveSupport::TestCase

   def setup 
      Rails.application.load_seed 
   end     

   test "Short topic names" do 
      Topic.all.each do |t|
         assert t.shortName.split.count == 1, "Short name for topic #{t.name} is incorrect"        
      end 
   end 

   test "Topic icons" do 
      Topic.all.each do |t|    
         path = "app/assets/images/icons/#{t.shortName}.png"
         assert File.file?(path), "Could not find icon #{t.shortName}"
      end 
   end 

   test "Each level has questions" do

      Topic.all.each do |t|
         t.numberOfLevels.times do |l|
            if l != 1 
               name = t.levelName(l)
               assert t.fetchQuestionIDsForLevel(name) != [], "Question IDs should be returned for all levels"
            end
         end
      end 
   end
  
end
