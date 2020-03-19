# frozen_string_literal: true

class TeachingController < EndUserController
  respond_to :html, :xml, :jpg, :js

  # Helper method to open and send images embedded within teaching pages 
  # def fetchImage
  #   fullPathString = expandImagePath(params[:id])
  #   path = Dir[fullPathString + '.*']
  #   img = File.open(path.first)
  #   send_data(img.read)
  #   img.close
  # end

  # Display a teaching page. As these pages are split into sections, 
  # the material is shown in a partial view that is updated via JS
  # requests to this function. When the last section is reached the 
  # level is set as "viewed"
  # 
  # @param :id [Int] topic ID, when landing from an automatically generated link 
  # @param :forLevel [String] short level name 
  # @param :currentPart [Int] optional, number from 0 of the desired next section
  def show
    # HTML response for the first time landing on a level, JS thereafter. 
    respond_to :html, :js 

    # begin 
      @topic = Topic.find(params[:id])
      params[:id] = @topic.id
      @level = params[:forLevel].to_i

      # Attempt to get the paths for this topic and level. Returns nil if files not found.
      @paths = @topic.paths[@level]

      # Get current part, if it exists, or initialise to 0.
      @currentPart = ((p = params[:currentPart]) ? p.to_i : 0)
      path = @paths[@currentPart]
      @flatHTMLString = File.read(path)

      if not File.exist?(path)
        redirect_to @topic 
        flash[:error] = "Error loading #{path}"
        return 
      end 

      # If this is the last page of the level, set the level as viewed
      if @currentPart + 1 == @paths.count
        current_user.setLevelViewed(@topic.id, @level) unless (current_user.inAdminMode || current_user.revisionMode) 
      end

  end

  # Send XML or JPG files for webrotate. Requests are caught and
  # routed to their location in the teaching folder. 
  # 
  # @param :path [String] path suffix to be appended to 'teaching/...'
  # @param :format [String] extension of desired file (XML or JPG)
  def webrotateXMLJPG
    path = params[:path]
    path = 'teaching/' + params[:path] + ".#{params[:format]}"
    if File.exist? path
      send_file(path)
    else
      render status: 418  # If fail then return coffee pot status 
    end
  end

  # Send webrotate assets. 
  # 
  # @param :path [String] path suffix to be appended to 'vendor/assets/webrotate...'
  # @param :format [String] extension of desired file 
  def webrotate_assets
    path = params[:path]
    path = 'vendor/assets/webrotate/' + path + ".#{params[:format]}"
    if File.exist? path
      send_file(path)
    else
      render status: 418 # If fail then return coffee pot status 
    end
  end

end
