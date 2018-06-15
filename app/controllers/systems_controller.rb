# frozen_string_literal: true

class SystemsController < EndUserController
  def index
    @systems = System.all
    @systemNames = @systems.map(&:name)
    @pathStubs = @systems.map { |s| '/' + s.id.to_s }
    @iconStubs = @systems.map(&:shortName)
  end

  def show
    @system = System.find(params[:id])
    @topics = @system.topics
    @topicNames = @topics.map(&:name)
    @pathStubs = @topics.map { |t| t.id.to_s }
    @iconStubs = @topics.map(&:shortName)
    @path_root = topics_path + '/'
  end
end
