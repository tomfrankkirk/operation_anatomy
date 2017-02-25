class TeachingController < EndUserController

    def show
        @topic = Topic.find( params[:forTopic] )
        # Attempt to get the requested resource (normally just a static html response)
        # If unsuccessful then render the error message
        render 'error'
    end

    private
    def teachingPagePath 
        name = @topic.name
        level = params[:forLevel]
        return "/#{name}/#{name}L#{level}.html"
    end

    
end
