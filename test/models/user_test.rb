# frozen_string_literal: true

require 'test_helper'
  # TODO update user tests as lots of bugs re level access made it through 

class UserTest < ActiveSupport::TestCase
  def setup
    Rails.application.load_seed
  end

  test 'Nil score for new user' do
    user = User.new
    topic = Topic.first
    levelName = topic.levelName(0)
    assert user.getLevelScore(topic.id, levelName) == 0, 'Level score for new user should be 0'
  end

  test 'New user has not viewed introduction yet' do
    user = User.new
    topic = Topic.first
    assert user.getHighestViewedLevel(topic.id) == -1, 'User has not viewed intro so should be -1'
  end

  test 'New user has passed no levels' do 
    user = User.new 
    topic = Topic.first 
    assert user.getHighestLevelPassed(topic.id) == -1, 'New user max level passed should be -1'
  end 

  test 'New user has no level access' do
    user = User.new
    topic = Topic.first
    assert user.checkLevelAccess(topic.id) == -1, 'Level access for new user should be -1'
  end

  test 'L0 view is recorded' do
    user = User.new
    topic = Topic.first
    l0 = topic.levelName(0)
    user.setLevelViewed(topic.id, l0)
    assert user.getHighestViewedLevel(topic.id) == 0, 'Highest viewed level should be 0'
  end
  
  test 'After L0 view, dummy score initialised' do 
    user = User.new
    topic = Topic.first
    l0 = topic.levelName(0)
    user.setLevelViewed(topic.id, l0)
    assert user.getHighestLevelPassed(topic.id) == 0, 'Highest viewed passed should be 0'
  end

  test 'No access to level 1 questions after only level 0 viewed' do
    user = User.new
    topic = Topic.first
    l0 = topic.levelName(0)
    user.setLevelViewed(topic.id, l0)
    assert user.checkLevelAccess(topic.id) == 0, 'Level access should be 0 after only viewing intro'
  end 

  test 'Access to L1 questions after viewing L0 and L1' do 
    user = User.new
    topic = Topic.first
    l0 = topic.levelName(0)
    l1 = topic.levelName(1)
    user.setLevelViewed(topic.id, l0)
    user.setLevelViewed(topic.id, l1)
    assert user.checkLevelAccess(topic.id) == 1, 'After viewing L0/1 should have access to L1 questions'
  end

  test 'Access to L2 questions after viewing L0/1/2 and sitting L1' do 
    user = User.new
    topic = Topic.first
    l0 = topic.levelName(0)
    l1 = topic.levelName(1)
    l2 = topic.levelName(2)
    user.setLevelViewed(topic.id, l0)
    user.setLevelViewed(topic.id, l1)
    user.setLevelViewed(topic.id, l2)
    user.updateLevelScore(topic.id, l1, 100)
    assert user.checkLevelAccess(topic.id) == 2
  end

  test 'No access to L2 questions after only viewing L0/1/2' do 
    user = User.new
    topic = Topic.first
    l0 = topic.levelName(0)
    l1 = topic.levelName(1)
    l2 = topic.levelName(2)
    user.setLevelViewed(topic.id, l0)
    user.setLevelViewed(topic.id, l1)
    user.setLevelViewed(topic.id, l2)
    assert user.checkLevelAccess(topic.id) == 1
  end

  test 'Write a test score' do
    user = User.new
    topic = Topic.first
    l0 = topic.levelName(0)
    l1 = topic.levelName(1)
    user.setLevelViewed(topic.id, l0)
    user.setLevelViewed(topic.id, l1)
    score = 100 * Random.rand
    assert user.updateLevelScore(topic.id, l1, score), 'Should be able to update score for new user'
    assert user.getLevelScore(topic.id, l1) == score, 'Retrieved score does not match generated score'
  end

  test 'Check level access after score under threshold' do
    user = User.new
    topic = Topic.first
    l0 = topic.levelName(0)
    l1 = topic.levelName(1)
    user.setLevelViewed(topic.id, l0)
    user.setLevelViewed(topic.id, l1)
    user.updateLevelScore(topic.id, l1, 30)
    assert user.checkLevelAccess(topic.id) == 1, 'Low score so should only have access to level 1'
  end

  test 'Check level access after high score but no view' do
    user = User.new
    topic = Topic.first
    l0 = topic.levelName(0)
    l1 = topic.levelName(1)
    user.setLevelViewed(topic.id, l0)
    user.setLevelViewed(topic.id, l1)
    user.updateLevelScore(topic.id, l1, 90)
    assert user.checkLevelAccess(topic.id) == 1, 'Score was high but have not yet viewed level 2 so remain on level 1 access'
  end

  test 'Correct number of questions sent user on for each level' do
    u = User.new
    Topic.all.each do |t|
      t.numberOfLevels.times do |l|
        next unless l != 0
        name = t.levelName(l)
        count = t.fetchQuestionIDsForLevel(name).count
        u.prepareQuestions(t.id, name)
        count.times do |q|
          assert !u.sendNextQuestionID.nil?, 'Could not pop next question from user object.'
        end
      end
    end
  end

  # test 'Attempt questions and save score' do
  #   u = User.new
  #   Topic.all.each do |t|
  #     (2..t.numberOfLevels).each do |l|
  #       name = t.levelName(l)
  #       u.setLevelViewed(t.id, name)
  #       count = t.fetchQuestionIDsForLevel(name).count
  #       u.prepareQuestions(t.id, name)
  #       score = 0

  #       count.times do |_n|
  #         q = Question.find(u.sendNextQuestionID)
  #         resp = q.shuffledSolutions.first
  #         score += 1 if q.respond(resp)
  #         u.incrementCurrentScore if q.respond(resp)
  #       end

  #       u.hasFinishedQuestions(t.id, name)
  #       score = (100 * (score / count.to_f)).round

  #       assert u.getLastScore(t.id, name)[:score] == score, 'Score recorded on the user object does not match calculated score'
  #     end
  #   end
  # end

end 
 