class UsersController < EndUserController

	def index
		if current_user.isAdmin
			@users = User.all
		else
			redirect_to root_path
		end 
	end 

	def show
		if current_user.isAdmin
			@user = User.find(params[:id])
			@topics = Topic.all
		else
			redirect_to root_path
		end 
	end 

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

end
