# frozen_string_literal: true

class TopicsController < EndUserController

  # Topics should not be directly indexable: redirect back to systems. 
  # This is a hangover from the fact that topics are listed as a resource 
  # in order to have access to their path helpers in other areas. 
  def index
    redirect_to systems_url 
  end

  # Show levels within a topic. If landing back here from a level then 
  # wipe the level number from the session. 
  def show
    @topic = Topic.find(params[:id])
    @revisionMode = current_user.revisionMode
    @admin = (current_user.isAdmin && current_user.inAdminMode)

    # If not in revision mode, check max level access, otherwise set as nil.
    @maxLevelAccess = @revisionMode ? nil : current_user.levelAccess(@topic.id) 
    @maxViewAccess = current_user.highestViewedLevel(@topic.id) + 1

    # Prepare items for the table cell view. 
    @iconNames = @topic.levelNames
    @pathRoot = "/teaching?id=#{@topic.id}&forLevel="
    @pathStubs = (0..@iconNames.count-1).to_a.map { |i| i.to_s }
    @iconStubs = @topic.level_names

    # Reset the session parameters. 
    session[:forLevel] = nil
    session[:topicID] = @topic.id
  end
  
end
