# frozen_string_literal: true

require 'test_helper'

class TeachingControllerTest < ActionDispatch::IntegrationTest
  def setup
    Rails.application.load_seed
  end

  test 'teaching pages exist' do
    Topic.all.each do |t|
      t.shortLevelNames.each do |l|
        path = "/teaching/#{t.shortName}/#{l}/*"
        assert Dir[Dir.pwd + path] != [], "Could not find teaching pages for #{t.shortName}, #{l}"
      end
    end
  end
end
