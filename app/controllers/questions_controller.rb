class QuestionsController < ApplicationController

    def respond
        @user = _findUser

        respond_to do |format|  

            # This is the first responder for the topic level. 
            format.html { 
                session[:forLevel] = params[:forLevel]
                @user.prepareQuestions(params[:forTopic], params[:forLevel])
                render 'respond' 
            } 

            # This is the responder for all other responses, it updates the partial on the page. 
            # When there are no more questions, log final score and redirect. 
            format.js {
                # First, check the user's response against the question.
                # Log the outcome.  
                if response = params[:userResponse]
                    puts "User response here"
                    puts response
                    session[:currentScore] = session[:currentScore] + 1 
                end

                # Then, send the next question. 
                if @qID = @user.sendNextQuestionID
                    @question = Question.find(@qID)

                # If no more questions, record final score (extracted from session cookie)
                # Convert to percentage and send off to the user db
                # Put all of this functionality into the user object?
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
