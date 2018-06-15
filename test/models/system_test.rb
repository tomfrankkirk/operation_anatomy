# frozen_string_literal: true

require 'test_helper'

class SystemTest < ActiveSupport::TestCase
  def setup
    Rails.application.load_seed
  end

  test 'short system names' do
    System.all.each do |s|
      assert s.shortName.split.count == 1, "Short name for topic #{s.name} is incorrect"
    end
  end

  test 'system icons' do
    System.all.each do |s|
      path = "app/assets/images/icons/#{s.shortName}.png"
      assert File.file?(path), "Could not find icon #{s.shortName}"
    end
  end

  test 'level names' do
    System.all.each do |s|
      s.shortLevelNames.each do |l|
        path = "app/assets/images/icons/#{l}.png"
        assert File.file?(path), "Could not find icon #{l}"
      end
    end
  end
end
