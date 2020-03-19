# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    Rails.application.load_seed
  end

  test 'Nil score for new user' do
    user = User.new
    topic = Topic.first
    assert user.getScore(topic.id, 0) == 0, 'Level score for new user should be 0'
  end

  test 'New user has not viewed introduction yet' do
    user = User.new
    topic = Topic.first
    assert user.highestViewedLevel(topic.id) == -1, 'User has not viewed intro so should be -1'
  end

  test 'New user has passed no levels' do 
    user = User.new 
    topic = Topic.first 
    assert user.highestPassedLevel(topic.id) == -1, 'New user max level passed should be -1'
  end 

  test 'New user has no level access' do
    user = User.new
    topic = Topic.first
    assert user.levelAccess(topic.id) == 0, 'Level access for new user should be 0'
  end

  test 'L0 view is recorded' do
    user = User.new
    topic = Topic.first
    user.setLevelViewed(topic.id, 0)
    assert user.highestViewedLevel(topic.id) == 0, 'Highest viewed level should be 0'
  end
  
  test 'After L0 view, dummy score initialised' do 
    user = User.new
    topic = Topic.first
    user.setLevelViewed(topic.id, 0)
    assert user.highestPassedLevel(topic.id) == 0, 'Highest viewed passed should be 0'
  end

  test 'After viewing level 0 and dummy score, access level 1' do
    user = User.new
    topic = Topic.first
    user.setLevelViewed(topic.id, 0)
    assert user.levelAccess(topic.id) == 1
  end 

  test 'Access to L1 questions after viewing L0 and L1' do 
    user = User.new
    topic = Topic.first
    user.setLevelViewed(topic.id, 0)
    user.setLevelViewed(topic.id, 1)
    assert user.levelAccess(topic.id) == 1, 'After viewing L0/1 should have access to L1 questions'
  end

  test 'Access to L2 questions after viewing L0/1/2 and sitting L1' do 
    user = User.new
    topic = Topic.first
    user.setLevelViewed(topic.id, 0)
    user.setLevelViewed(topic.id, 1)
    user.setLevelViewed(topic.id, 2)
    user.setScore(topic.id, 1, 100)
    assert user.levelAccess(topic.id) == 2
  end

  test 'No access to L2 questions after only viewing L0/1/2' do 
    user = User.new
    topic = Topic.first
    user.setLevelViewed(topic.id, 0)
    user.setLevelViewed(topic.id, 1)
    user.setLevelViewed(topic.id, 2)
    assert user.levelAccess(topic.id) == 1
  end

  test 'Write a test score' do
    user = User.new
    topic = Topic.first
    user.setLevelViewed(topic.id, 0)
    user.setLevelViewed(topic.id, 1)
    score = 100 * Random.rand
    assert user.setScore(topic.id, 1, score), 'Should be able to update score for new user'
    assert user.getScore(topic.id, 1) == score, 'Retrieved score does not match generated score'
  end

  test 'Check level access after score under threshold' do
    user = User.new
    topic = Topic.first
    user.setLevelViewed(topic.id, 0)
    user.setLevelViewed(topic.id, 1)
    user.setScore(topic.id, 1, 30)
    assert user.levelAccess(topic.id) == 1, 'Low score so should only have access to level 1'
  end

  test 'Check level access after viewing and passing L1' do
    user = User.new
    topic = Topic.first
    user.setLevelViewed(topic.id, 0)
    user.setLevelViewed(topic.id, 1)
    user.setScore(topic.id, 1, 90)
    assert user.levelAccess(topic.id) == 2
  end

  test 'Correct number of questions sent user on for each level' do
    u = User.new
    Topic.all.each do |t|
      t.numberOfLevels.times do |l|
        next unless l != 0
        count = t.fetchQuestionIDsForLevel(l).count
        u.prepareQuestions(t.id, l)
        count.times do |q|
          assert !u.sendNextQuestionID.nil?, 'Could not pop next question from user object.'
        end
      end
    end
  end

end 
 