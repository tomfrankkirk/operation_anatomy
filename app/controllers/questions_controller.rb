class QuestionsController < ApplicationController

    # Hardcoded to fetch tom from db. 

    def show
        @user = User.find(session[:userID])
        puts "Gathering questions for user with id #{ ( User.find( session[:userID] ) ).id }"
        session[:questionIDs] = (Topic.find(params[:id])).fetchQuestionIDsForLevel(params[:forLevel])
        #@user.prepareQuestionsForUserResponse(params[:id], params[:forLevel])
    end

    def respond
        
    end 

    private 
    def question_params
        params.require(:question).permit(:body, :level)
    end

end
