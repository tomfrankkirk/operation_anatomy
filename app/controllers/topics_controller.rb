class TopicsController < EndUserController

    def index
        # When landing back here from a topic, wipe the topic id from the session. 
        session[:topicID] = nil 
        @topics = Topic.all
        @revisionMode = current_user.revisionMode
        @admin = current_user.isAdmin 
    end

    def show 
        # If landing back here from a set of questions, wipe the level id from the session. 
        @topic = Topic.find(params[:id])
        session[:forLevel] = nil 
        session[:topicID] = @topic.id
        @revisionMode = current_user.revisionMode
        @admin = current_user.isAdmin
    end

end
