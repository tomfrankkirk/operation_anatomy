# frozen_string_literal: true

class TopicsController < EndUserController
  # When landing back here from a topic, wipe the topic id from the session.
  def index
    session[:topicID] = nil
    @topics = Topic.all
    @revisionMode = current_user.revisionMode
    @admin = current_user.isAdmin && current_user.inAdminMode
  end

  # If landing back here from a set of questions, wipe the level id from the session.
  # Then rewrite the id in and continue.
  def show
    @topic = Topic.find(params[:id])
    @revisionMode = current_user.revisionMode

    # If not in revision mode, check max level access, otherwise set as nil.
    @maxLevelAccess = @revisionMode ? nil : current_user.checkLevelAccess(@topic.id)

    @admin = current_user.isAdmin && current_user.inAdminMode
    @highestViewed = current_user.getHighestViewedLevel(@topic.id)
    @levelNames = @topic.levelNames
    @pathRoot = "/teaching?id=#{@topic.id}&forLevel="
    @pathStubs = @topic.shortLevelNames
    @iconStubs = @topic.shortLevelNames
    session[:forLevel] = nil
    session[:topicID] = @topic.id
  end
end
