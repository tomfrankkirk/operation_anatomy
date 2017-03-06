class TeachingController < EndUserController

    def assetRequest
        pathStr = 'teaching/*/' + params[:id] + '.' + params[:format]
        path = Dir[pathStr]
        img = File.open(path.first)
        send_data(img.read)
        img.close
    end

    def show
        @topic = Topic.find(params[:forTopic])
        name = @topic.name 

        # Attempt to get the paths for this topic and level. Returns nil if files not found. 
        @paths = teachingPagePaths(name, params[:forLevel])

        respond_to do |format| 

            # First page load. Set currentPart = 0 and pass all paths off to the view to render. 
            # The forward/backwards links are dynamically generated within the view by comparing
            # currentPart with the total number of parts loaded (the count of paths)
            format.html {
                if @paths
                    @currentPart = 0
                else 
                    # If unsuccessful then render the error message
                    render 'error'
                end        
            }

            # Simply increment or decrement currentPart and re-load. 
            format.js {
                @currentPart = (params[:currentPart]).to_i        
            }
        end
    end

    def define
        respond_to do |format|
            format.json { 

                # Check the param searchString was successfully received. 
                if string = params[:searchString]
                    entry = DictionaryEntry.searchForEntry(string)
                    if entry 
                        render :json => { :definition => entry.definition, :title => entry.title, :example => entry.example }
                        return 
                    end 
                end 

                # If not, return an empty hash 
                render :json => { :definition => "" }     
            }
        end
    end

    private
    def teachingPagePaths(forTopicName, forLevel)
        pathStr = 'teaching/' + forTopicName + '/' + forTopicName + 'L' + forLevel.to_s + '*'
        paths = Dir[pathStr]
        if paths == []
            return nil 
        else 
            return paths 
        end
    end
    
end
