# frozen_string_literal: true

class TeachingController < EndUserController
  include RoutingHelpers 
  respond_to :html, :xml, :jpg, :js

  # Helper method to open and send images embedded within teaching pages 
  def fetchImage
    fullPathString = expandImagePath(params[:id])
    path = Dir[fullPathString + '.*']
    img = File.open(path.first)
    send_data(img.read)
    img.close
  end

  # Display a teaching page. As these pages are split into sections, 
  # the material is shown in a partial view that is updated via JS
  # requests to this function. When the last section is reached the 
  # level is set as "viewed"
  # 
  # @param :id [Int] topic ID, when landing from an automatically generated link 
  # @param :forLevel [String] short level name 
  # @param :currentPart [Int] optional, number from 0 of the desired next section
  def show
    
    @topic = Topic.find(params[:id])
    if @topic.nil? 
      flash[:error] = 'Error loading teaching page'
      redirect_to topics_path
      return 
    end 

    # Attempt to get the paths for this topic and level. Returns nil if files not found.
    params[:id] = @topic.id
    @level = params[:forLevel]

    if @paths = teachingPagePaths(@topic.shortName, @level)

      # Get current part, if it exists, or initialise to 0.
      @currentPart = ((p = params[:currentPart]) ? p.to_i : 0)
      @path = @paths[@currentPart]
 
      # If this is the last page of the level, set the level as viewed
      if @currentPart + 1 == @paths.count
        current_user.setLevelViewed(@topic.id, @level) unless (current_user.inAdminMode || current_user.revisionMode) 
      end

      @flatHTMLString = File.read(@path)

    # If unsuccessful then render the error message
    else
      render 'error'
    end

    # HTML response for the first time landing on a level, JS thereafter. 
    respond_to do |format|
      format.html
      format.js
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

  private

  # Send both HTML and ERB pages at the given location.
  # 
  # @param topicName [String] short topic name 
  # @param forLevel [String] short level name 
  # @return [[String]] paths, sorted from part 0 to N (N < 10)
  def teachingPagePaths(topicName, forLevel)
    begin 
      pathStr = teachingDirectory(topicName, forLevel) 
      paths = Dir[pathStr + '*.html']
      if paths == []
        return nil
      else
        return paths.sort_by do |s|
          # Some funky regexp -- disabled and back to simple extract last number between P and html! s[/\d{2,}/].to_i
          # so make sure that there are less than 10 pages in a level...
          s[s.rindex('P') + 1..s.rindex('.html') - 1].to_i
        end 
      end
    rescue 
      return nil 
    end 
  end

end
