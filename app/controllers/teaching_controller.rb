class TeachingController < EndUserController

   respond_to :html, :xml, :jpg, :js

   def fetchImage
      fullPathString = expandImagePath(params[:id]) 
      path = Dir[fullPathString + ".*"]
      img = File.open(path.first)
      send_data(img.read)
      img.close
   end

   # This method updates teaching page partials via JS ajax requests. 
   # It is also responsible for setting "level viewed" flags when the user reaches end of level 
   def show
      @topic = Topic.find(params[:id]) 
      @level = params[:forLevel]

      # Attempt to get the paths for this topic and level. Returns nil if files not found. 
      @paths = teachingPagePaths(@topic.shortName, @level)

      if @paths

         # Get current part, if it exists, or initialise to 0. 
         @currentPart = (params[:currentPart]).to_i
         @currentPart = 0 if @currentPart.nil? 

         # byebug
         # Check if this is the end of the level, if so set flag on user object if not admin mode
         if @currentPart + 1 == @paths.count
            current_user.setLevelViewed(@topic.id, @level) unless current_user.inAdminMode
         end 

         # Retrieve the part from the paths array. 
         @path = @paths[@currentPart]
         @flatHTMLString = nil 

         if @path.include? '.erb'
            # We need to prepare the erb here...
            # Define the local vars here.... 
            @rawStr = File.read(@path)
            template = ERB.new(@rawStr)
            @flatHTMLString = template.result(binding)
         else 
            @flatHTMLString = File.read(@path)
         end 

      else 

         # If unsuccessful then render the error message
         render 'error'
      end        

      respond_to do |format| 
         format.html
         format.js 
      end
   end

   def webrotateXMLJPG
      # What kind of path are we working with?
      path = params[:path]
      path = "teaching/" + params[:path] + ".#{params[:format]}"
      if File.exist? path 
         send_file(path)
      else 
         render :status => 418
      end 
   end 

   def webrotate_assets
      path = params[:path]    
      path = "vendor/assets/webrotate/" + path + ".#{params[:format]}"
      if File.exist? path 
         send_file(path)
      else 
         head 418 
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
         return paths.sort_by { |s| s[/\d{2,}/].to_i }  # Some funky regexp!
      end
   end

   #  def expandImagePath(imageName)
   #      imageName = imageName.sub('/images/', '')
   #      topic = imageName.slice(0, imageName.index('L')) 
   #      level = imageName.slice((imageName.index('L') + 1) .. (imageName.index('P' ) - 1) ) 
   #      part = imageName.slice((imageName.index('P') + 1) .. (imageName.index('Image') - 1) )
   #      path = 'teaching/' + topic + '/L' + level + '/images/' + imageName
   #      return path 
   #  end 

end
