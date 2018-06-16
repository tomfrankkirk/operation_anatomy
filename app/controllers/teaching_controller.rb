# frozen_string_literal: true

class TeachingController < EndUserController
  respond_to :html, :xml, :jpg, :js

  # Helper method to open and send images embedded within teaching pages 
  def fetchImage
    fullPathString = expandImagePath(params[:id])
    path = Dir[fullPathString + '.*']
    img = File.open(path.first)
    send_data(img.read)
    img.close
  end

  # Update the partial view on a teaching page via JS. When last page is 
  # reached set the appropriate level viewed flag. 
  def show
    # First check if this is a  auto-generated path or a manual one written
    # directly into the HTML (a link between pages). Manual ones are passed 
    # around with a "topic" param, whereas auto ones are with an "id" param.
    # If manual we load the topic via its name, pop the ID into the params hash 
    # and then carry on as normal.
    if name = params[:topic]
      @topic = Topic.where(name: name).first 
    else
      @topic = Topic.find(params[:id])
    end 

    # Attempt to get the paths for this topic and level. Returns nil if files not found.
    params[:id] = @topic.id
    @level = params[:forLevel]
    @paths = teachingPagePaths(@topic.shortName, @level)

    if @paths

      # Get current part, if it exists, or initialise to 0.
      @currentPart = (p = params[:currentPart]) ? p.to_i : 0 
      @path = @paths[@currentPart]

      # If this is the last page of the level, set the level as viewed
      if @currentPart + 1 == @paths.count
        current_user.setLevelViewed(@topic.id, @level) unless (current_user.inAdminMode || current_user.inRevisionMode) 
      end

      # Behaviour here depends if the page includes a hard-coded link to another
      # teaching page (flagged via the .erb extension). If so we preprocess to 
      # generate the link dynamically. 
      if @path.include? '.erb'
        @rawStr = File.read(@path)
        template = ERB.new(@rawStr)
        @flatHTMLString = template.result(binding)
      else
        @flatHTMLString = File.read(@path)
      end

    # If unsuccessful then render the error message
    else
      render 'error'
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  # Send XML or JPG files for webrotate. Requests are caught and
  # routed to their location in the teaching folder. 
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
  def webrotate_assets
    path = params[:path]
    path = 'vendor/assets/webrotate/' + path + ".#{params[:format]}"
    if File.exist? path
      send_file(path)
    else
      head 418 # If fail then return coffee pot status 
    end
  end

  private

  # Search for both HTML and ERB pages at the given location.
  def teachingPagePaths(topicName, forLevel)
    pathStr = 'teaching/' + topicName + '/' + forLevel + '/*'
    paths = Dir[pathStr].select { |f| File.file? f }
    if paths == []
      return nil
    else
      return paths.sort_by do |s|
        s[s.rindex('P') + 1..s.rindex('.html') - 1].to_i
      end # Some funky regexp -- disabled and back to simple extract last number between P and html! s[/\d{2,}/].to_i
    end
  end
end
