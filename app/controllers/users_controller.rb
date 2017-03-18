class UsersController < EndUserController

def submitFeedback()
	respond_to do |format|
		format.js {
			puts "Feedback submitted"
			if userID = params[:userID]
				tone = params[:tone]
				comment = params[:comment]
				record = FeedbackRecord.new(tone: tone, comment: comment)
				record.user_id = userID
				record.save 
				render :json => {:success => true}
			end 
		}
	end
end

end
