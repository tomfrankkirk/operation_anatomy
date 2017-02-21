class TopicsController < ApplicationController

  def index
      @userID = session[:userID]
      @topics = Topic.all
  end

  def show 
      @user = User.find(session[:userID])
      @topic = Topic.find(params[:id])
      session[:topicID] = @topic.id
  end


end
