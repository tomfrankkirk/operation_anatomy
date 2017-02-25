class TopicsController < EndUserController

  def index
      # When landing back here from a topic, wipe the topic id from the session. 
      session[:topicID] = nil 
      @topics = Topic.all
  end

  def show 
      # If landing back here from a set of questions, wipe the level id from the session. 
      session[:forLevel] = nil 
      # Record these bits of info. 
      @topic = Topic.find(params[:id])
      session[:topicID] = @topic.id
  end

end
