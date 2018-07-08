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

  # Display a teaching page. As these pages are split into sections, 
  # the material is shown in a partial view that is updated via JS
  # requests to this function. When the last section is reached the 
  # level is set as "viewed"
  # 
  # @param :topic [String] short topic name, when landing from a manually defined link
  # @param :id [Int] topic ID, when landing from an automatically generated link 
  # @param :forLevel [String] short level name 
  # @param :currentPart [Int] optional, number from 0 of the desired next section
  def show
    
    # First check if this is a  auto-generated path or a manual one written
    # directly into the HTML (a link between pages). Manual ones are passed 
    # around with a "topic" param, whereas auto ones are with an "id" param.
    # If manual we load the topic via its name, pop the ID into the params hash 
    # and then carry on as normal.
    if name = params[:topic]
      @topic = (Topic.select { |t| t.shortName == name }).first 
    else
      @topic = Topic.find(params[:id])
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
      head 418 # If fail then return coffee pot status 
    end
  end

  private

  # Send both HTML and ERB pages at the given location.
  # 
  # @param topicName [String] short topic name 
  # @param forLevel [String] short level name 
  # @return [[String]] paths, sorted from part 0 to N (N < 10)
  def teachingPagePaths(topicName, forLevel)
    pathStr = 'teaching/' + topicName + '/' + forLevel + '/*'
    paths = Dir[pathStr].select { |f| File.file? f }
    if paths == []
      return nil
    else
      return paths.sort_by do |s|
        # Some funky regexp -- disabled and back to simple extract last number between P and html! s[/\d{2,}/].to_i
        # so make sure that there are less than 10 pages in a level...
        s[s.rindex('P') + 1..s.rindex('.html') - 1].to_i
      end 
    end
  end

  # Helper method to dynamically fill-in manually specified links within 
  # teaching pages. Before a page is served up, ERBs are templated in the 
  # controller's scope which allows the the arguments defined within the page
  # to be passed into the function, which then generates the a href tags
  # and serves them up. Arguments should mirror the structure of the 
  # teaching directory. 
  # 
  # @param destTopic [String] short topic name eg shoulder
  # @param destLevel [String] short level name eg bones
  # @param linkBody [String] the body of the link to display 
  # @param destPart [Int] optional, part number to direct to (zero index)
  def manualLink(destTopic, destLevel, linkBody, destPart=nil)
    if destPart
      "<a href='/teaching?topic=#{URI::encode(destTopic)}&forLevel=#{destLevel.downcase}&currentPart=#{destPart}'> #{linkBody} </a>"
    else 
      "<a href='/teaching?topic=#{URI::encode(destTopic)}&forLevel=#{destLevel.downcase}'> #{linkBody} </a>"
    end 

  end 
end
