require 'test_helper'

class UserTest < ActiveSupport::TestCase

   def setup 
      Rails.application.load_seed 
   end     
   
   test "Nil score for new user" do 
      user = User.new
      topic = Topic.first 
      levelName = topic.levelName(0)

      assert user.getLevelScore(topic.id, levelName).nil?, "Level score for new user should be nil"
   end 

   test "New user has not viewed introduction yet" do 
      user = User.new
      topic = Topic.first 
      levelName = topic.levelName(0)
      assert user.getHighestViewedLevel(topic.id) == 0, "User has not viewed intro so should be 0"
   end 

   test "Zero level access for user" do 
      user = User.new
      topic = Topic.first 
      levelName = topic.levelName(0)
      assert user.checkLevelAccess(topic.id) == 0, "Level access for new user should be zero"
   end 

   test "Check max level viewed after first level view" do
      user = User.new
      topic = Topic.first 
      l1 = topic.levelName(0)
      l2 = topic.levelName(1)
      user.setLevelViewed(topic.id, l1)
      user.setLevelViewed(topic.id, l2) 
      assert user.getHighestViewedLevel(topic.id) == 1, "Highest viewed level should be 1"
   end

   test "Level access after viewing introduction and first level" do 
      user = User.new
      topic = Topic.first 
      l1 = topic.levelName(0)
      l2 = topic.levelName(1)
      user.setLevelViewed(topic.id, l1)
      user.setLevelViewed(topic.id, l2) 
      assert user.checkLevelAccess(topic.id) == 1, "After viewing levels 0 and 1, should have access to L1"
   end 

   test "Write a test score" do 
      user = User.new
      topic = Topic.first 
      l1 = topic.levelName(0)
      l2 = topic.levelName(1)
      user.setLevelViewed(topic.id, l1)
      user.setLevelViewed(topic.id, l2) 

      score = 100*Random.rand
      assert user.updateLevelScore(topic.id, l2, score), "Should be able to update score for new user"
      assert user.getLevelScore(topic.id, l2) == score, "Retrieved score does not match generated score"
   end 

   test "Check level access after score under threshold" do 
      user = User.new
      topic = Topic.first 
      l1 = topic.levelName(0)
      l2 = topic.levelName(1)
      user.setLevelViewed(topic.id, l1)
      user.setLevelViewed(topic.id, l2) 

      score = 30 + 30*Random.rand
      user.updateLevelScore(topic.id, l2, score)
      assert user.checkLevelAccess(topic.id) == 1, "Low score so should only have access to level 1"
   end 

   test "Check level access after score over threshold and views" do 
      user = User.new
      topic = Topic.first 
      l1 = topic.levelName(0)
      l2 = topic.levelName(1)
      l3 = topic.levelName(2)
      user.setLevelViewed(topic.id, l1)
      user.setLevelViewed(topic.id, l2) 
      user.setLevelViewed(topic.id, l3) 
      
      score = 70 + 30*Random.rand
      user.updateLevelScore(topic.id, l2, score)
      assert user.checkLevelAccess(topic.id) == 2, "High score so should have access to L2"
   end 

   test "Check level access after high score but no view" do 
      user = User.new
      topic = Topic.first 
      l1 = topic.levelName(0)
      l2 = topic.levelName(1)
      user.setLevelViewed(topic.id, l1)
      user.setLevelViewed(topic.id, l2) 

      score = 70 + 30*Random.rand
      user.updateLevelScore(topic.id, l2, score)
      assert user.checkLevelAccess(topic.id) == 1, "Score was high but have not yet viewed level 2 so level 1 access"
   end

   test "Check level access after 2 high scores and level views" do 
      user = User.new
      topic = Topic.first 
      l1 = topic.levelName(0)
      l2 = topic.levelName(1)
      l3 = topic.levelName(2)
      l4 = topic.levelName(3)
      user.setLevelViewed(topic.id, l1)
      user.setLevelViewed(topic.id, l2) 
      user.setLevelViewed(topic.id, l3)
      user.setLevelViewed(topic.id, l4)
      
      score = 80
      assert user.updateLevelScore(topic.id, l2, score), "Should be able to update score for new user"
      assert user.updateLevelScore(topic.id, l3, score), "Should be able to update score for new user"
      assert user.checkLevelAccess(topic.id) == 3, "Score was high so should have access to level 3"
   end 

   test "Correct number of questions sent user on for each level" do 
      u = User.new 
      
      Topic.all.each do |t|
         t.numberOfLevels.times do |l|
            if l != 0 
               name = t.levelName(l)
               count = t.fetchQuestionIDsForLevel(name).count
               u.prepareQuestions(t.id, name)

               count.times do |q|
                  assert u.sendNextQuestionID != nil, "Could not pop next question from user object."
               end 
            end
         end
      end 
   end 

   test "Attempt questions and save score" do 
      u = User.new 

      Topic.all.each do |t| 
         (2 .. t.numberOfLevels).each do |l|
            name = t.levelName(l)
            count = t.fetchQuestionIDsForLevel(name).count
            u.prepareQuestions(t.id, name)
            score = 0 

            count.times do |n|
               q = Question.find(u.sendNextQuestionID)
               resp = q.shuffledSolutions.first
               score = score + 1 unless !q.respond(resp)
               u.incrementCurrentScore unless !q.respond(resp)
            end 
            
            u.hasFinishedQuestions(t.id, name)
            score = (100 * (score / count.to_f)).round
            
            assert u.getLastScore(t.id, name)[:score] == score, "Score recorded on the user object does not match calculated score"

         end 
      end 
   end 

end
