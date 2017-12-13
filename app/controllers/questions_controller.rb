class QuestionsController < EndUserController

    # Index action is available only to administrators, otherwise will redirect. 
    def index 
        if current_user.isAdmin
            @questions = Question.all
        else 
            # flash[:error] = "Sorry, this action is only available to administrators."
            redirect_to root_path 
        end 
    end 

    # This handles user interactions with questions. HTML response draws the initial page, 
    # thereafter questions are updated via a JS partial. 
    def respond

        respond_to do |format|  
            
            # First response, draw the HTML page. 
            format.html {  
                if @topic = Topic.find(params[:id].to_i) 
                    @name = @topic.name
                    @levelName = params[:levelName]
                    session[:id] = params[:id]
                    session[:levelName] = params[:levelName]
                    
                    current_user.prepareQuestions(@topic.id, @levelName)
                else 
                    # Didn't find the topic for some reason. Flash error?
                    render "error"
                end 
                return 
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
                    render "respond.js"
                    return 
                else
                    if !current_user.inAdminMode || current_user.inRevisionMode 
                        if !(current_user.hasFinishedQuestions(params[:id], params[:levelName]))  
                            flash[:errorMessage] = "Warning, could not save scores for previous level"
                        else 
                            score = current_user.getLastScore(params[:id], params[:levelName])
                            message = "You scored #{score["score"]}%."
                            message = "Congratulations! You scored #{score["score"]}% so the next level is available." unless score["score"] < User::Threshold
                            flash[:successMessage] = message 
                        end 
                    else 
                        flash[:successMessage] = "Raw admin score: #{current_user.currentScore}"
                    end 
                    render :js => "window.location = 'topics/#{params[:id]}'"
                end
             }  
        end
    end
    
end
