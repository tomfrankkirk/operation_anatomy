class QuestionsController < ApplicationController

    def respond
        @user = _findUser()


        respond_to do |format|  

            # This is the first responder for the topic level. 
            # Take the level into the sessions cookie for later. 
            # Prepare the questions on the user object and then
            # send the first one. 
            format.html { 
                session[:forTopic] = params[:forTopic]
                session[:forLevel] = params[:forLevel]
                @user.prepareQuestions(params[:forTopic], params[:forLevel])
                render 'respond' 
            } 

            # This is the responder for all other responses, it updates the partial on the page. 
            # When there are no more questions, log final score and redirect. 
            format.js {
                # Is the user sending a response through? Check by searching for the forQuestion params
                # If so, log the outcome of the response 
                if qid = params[:forQuestion]
                    if (Question.find(qid)).respond(params[:userResponse])
                        @user.incrementCurrentScore()
                    end
                end

                # Send the next question, if it exists
                # If it does not exist then log final score and send off to the db.
                if qID = @user.sendNextQuestionID()
                    @question = Question.find(qID)
                else
                    # THIS needs updating, how to pass an error message around?
                    if !(@user.hasFinishedQuestions(params[:forTopic], params[:forLevel]))  
                        errorMessage = "Warning, could not save scores for previous level"
                    else 
                        errorMessage = nil 
                    end
                render :js => "window.location = 'topics/#{params[:forTopic]}'"
                end
             }  
        end

    end

    private 
    
    def _findUser()
        return User.find(session[:userID])
    end

end
