class SessionsController < ApplicationController

  def new
    session[:userID] = params[:userID]
    redirect_to "/topics"
  end

  def destroy
  end

end
