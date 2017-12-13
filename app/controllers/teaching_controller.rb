class TeachingController < EndUserController

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
        respond_to do |format| 

            # First page load. Set currentPart = 0 and pass all paths off to the view to render. 
            # The forward/backwards links are dynamically generated within the view by comparing
            # currentPart with the total number of parts loaded (the count of paths)
            format.html {
                if @paths
                    @path = @paths.first 
                    @currentPart = 0
                    if @currentPart + 1 == @paths.count
                        current_user.setLevelViewed(@topic.id, @level)
                    end 
                else 
                    # If unsuccessful then render the error message
                    render 'error'
                end        
            }

            # Simply increment or decrement currentPart and re-load. 
            format.js {
                @currentPart = (params[:currentPart]).to_i
                @path = @paths.find { |p| p['P' + (@currentPart + 1).to_s] != nil }
                # Check if this is the end of the level, if so set flag on user object if not admin mode
                if @currentPart.to_i + 1 == @paths.count && !current_user.inAdminMode
                    current_user.setLevelViewed(@topic.id, @level)
                end 
            }
        end
    end

    def webRotateXML
        respond_to do |format|
            format.xml { 
                path = Dir["teaching/" + params[:path] + ".xml"]
                File.open(path.first, 'r') do |f| 
                    send_data(f.read)
                end 
            } 

            format.jpg {
                path = Dir["teaching/" + params[:path] + ".jpg"]
                File.open(path.first, 'r') do |f| 
                    send_data(f.read)
                end 
            }
        end 
    end 

   private

   def teachingPagePaths(forTopicName, forLevel)
      pathStr = 'teaching/' + forTopicName + '/' + forLevel + '/*.html'
      paths = Dir[pathStr]      
      if paths == []
         return nil 
      else 
         return paths.sort_by { |s| s[/\d+/].to_i }  # Some funky regexp!
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
