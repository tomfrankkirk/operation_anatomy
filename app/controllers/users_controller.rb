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
	def submitFeedback()
		respond_to do |format|
			format.js {
				puts "Feedback submitted"
				if userID = params[:userID]
					tone = params[:tone]
					comment = params[:comment]
					record = FeedbackRecord.new(tone: tone, comment: comment)
					record.user_id = userID
					if tone == "Bug"
						record.solved = false
					end 
					record.save 
					render :json => {:success => true}
				end 
			}
		end
	end

	# Function responds to remote JS calls to flip users in and out of admin mode. 
	# Then sends a message to the current page to refresh 
   def adminMode
      current_user.toggleAdminMode
		respond_to do |format|
			format.js {
            render :js => "location.reload();"
			}
		end 
   end 
   
   def revisionMode 
      current_user.toggleRevisionMode 
      respond_to do |format|
         format.js {
            render :js => "location.reload();"
         }
      end 
   end 

end
