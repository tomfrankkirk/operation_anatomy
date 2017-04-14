class QuestionsController < EndUserController

    # Index action is available only to administrators, otherwise will redirect. 
    def index 
        if current_user.isAdmin
            @questions = Question.all
        else 
            # flash[:error] = "Sorry, this action is only available to administrators."
            redirect_to "/questions_index"
        end 
    end 

    # This handles user interactions with questions. HTML response draws the initial page, 
    # thereafter questions are updated via a JS partial. 
    def respond
        respond_to do |format|  
            @admin = current_user.isAdmin && current_user.inAdminMode

            # First response, draw the HTML page. 
            format.html {  
                if t = Topic.find(params[:forTopic].to_i) 
                    @name = t.display_name 
                    @levelName = t.levelName(params[:forLevel].to_i)
                    session[:forTopic] = params[:forTopic]
                    session[:forLevel] = params[:forLevel]
                    current_user.prepareQuestions(params[:forTopic], params[:forLevel])
                else 
                    # Didn't find the topic for some reason. Flash error?
                    render "error"
                end 
            } 

            # This is the responder for all other responses, it updates the partial on the page. 
            # When there are no more questions, log final score and redirect. 
            format.js {
                # Is the user sending a response through? Check by searching for the forQuestion params
                # If so, log the outcome of the response 
                if qid = params[:forQuestion]
                    if (Question.find(qid)).respond(params[:userResponse])
                        current_user.incrementCurrentScore()
                    end
                end

                # Send the next question, if it exists
                # If it does not exist then log final score and send off to the db.
                if qID = current_user.sendNextQuestionID()
                    @question = Question.find(qID)
                else
                    if !(current_user.hasFinishedQuestions(params[:forTopic], params[:forLevel]))  
                        flash[:errorMessage] = "Warning, could not save scores for previous level"
                    end
                render :js => "window.location = 'topics/#{params[:forTopic]}'"
                end
             }  
        end
    end
    
end
