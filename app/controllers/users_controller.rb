# frozen_string_literal: true

class UsersController < EndUserController
  # Admin only method. List all users.
  def index
    if current_user.isAdmin
      @users = User.all
    else
      redirect_to root_path
    end
  end

  # Admin only method. Show detailed info about a user.
  def show
    if current_user.isAdmin
      @user = User.find(params[:id])
      @topics = Topic.all
    else
      redirect_to root_path
    end
  end

  # Logs a feedback record into the db under the users id. Remote method.
  def submitFeedback
    respond_to do |format|
      format.js do
        tone = params[:feedback][:tone]
        comment = params[:feedback][:comment]
        userID = params[:userID]
        ApplicationMailer.send_feedback(tone, comment, userID).deliver
        render body: nil
      end
    end
   end

  # Respond to remote JS call to flip the user in and out of admin mode. 
  # Then force reload 
  def adminMode
    current_user.toggleAdminMode
    respond_to do |format|
      format.js do
        render js: 'location.reload();'
      end
    end
  end

  # Respond to remote JS call to flip the user in and out of revision mode. 
  # Then force reload 
  def revisionMode
    current_user.toggleRevisionMode
    respond_to do |format|
      format.js do
        render js: 'location.reload();'
      end
    end
  end
end
