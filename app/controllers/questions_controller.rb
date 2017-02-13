class QuestionsController < ApplicationController

    def respond
        # @user = _findUser
        @message = "A message from the server to say hello"

        respond_to do |format|  

            format.html

            format.js { puts "JS FORMAT CALLED" }
  
            #     @topic = _findTopic
            #     puts "Gathering questions for user with id #{ @user.id }"
            #     @user.prepareQuestionsForUserResponse(@topic.id, params[:forLevel])
            #     @question = Question.find(@user.sendNextQuestion)
            #     render 'respond'
            # }


            #     puts params
            #     puts "Parameters go here"
            #     # The session cookie isn't being sent along with this - need to send the userID as part of the AJAX request. 
            #     puts "User response was #{params[:userResponse]}"
            #     @question = Question.find(@user.sendNextQuestion)
            #     puts "Sending next question "
            #     puts "Sending next question L#{@question.level}, N#{@question.number}"
            #     render json: { message: "Data from the server" }
            

        end

    end

    private 
    def _findUser
        User.find(session[:userID])
    end

    def _findTopic
        Topic.find(params[:forTopic])
    end

end
