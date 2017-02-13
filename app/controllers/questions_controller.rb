class QuestionsController < ApplicationController

    def respond
        @user = _findUser

        respond_to do |format|  

            format.html { 
                @user.prepareQuestions(params[:forTopic], params[:forLevel])
                render 'respond' 
            } 

            format.js {
                if @qID = @user.sendNextQuestionID
                    @question = Question.find(@qID)
                else
                    puts "no more questions"
                    render :js => "window.location = 'topics/#{params[:forTopic]}'"
                end
             }  

        end

    end

    private 
    def _findUser
        User.find(session[:userID])
    end

end
