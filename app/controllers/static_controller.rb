class StaticController < ApplicationController

    # A controller to handle the various static pages in the app. 
    def index 
    end

    def about
    end

    def help
    end

    def bugs 
        @bugs = FeedbackRecord.find_by("tone", "bug")
    end 

    def tech
    end

end
