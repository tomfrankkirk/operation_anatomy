# frozen_string_literal: true

require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  def setup
    Rails.application.load_seed
  end

  test 'Topic icons' do
    Topic.all.each do |t|
      path = "app/assets/images/icons/#{t.shortName}.png"
      assert File.file?(path), "Could not find icon #{t.shortName}"
    end
  end

  test 'Each topic has levels' do 
    Topic.all.each do |t|
      t.numberOfLevels.times do |l|
        assert !(t.levelName(l).nil?) 
      end 
    end 
  end 

  test 'Each level has questions' do
    Topic.all.each do |t|
      t.numberOfLevels.times do |l|
        if l != 0
          name = t.levelName(l)
          # byebug
          assert t.fetchQuestionIDsForLevel(name) != [], 'Question IDs should be returned for all levels'
        end
      end
    end
  end
end
