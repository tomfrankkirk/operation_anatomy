# frozen_string_literal: true

class QuestionsController < EndUserController
  # Index action is available only to administrators, otherwise will redirect.
  def index
    if current_user.isAdmin
      @questions = Question.all
    else
      redirect_to root_path
    end
  end

  # This handles user interactions with questions. HTML response draws the initial page,
  # thereafter questions are drawn onto the partial via JS.
  def respond
    respond_to do |format|
      
      # First response, draw the HTML page with a partial for questions
      # Prepare the questions on the user object, and save the topic ID and level name
      # into the session hash. This will be required when later updating via JS. 
      format.html do
        begin 
          @topic = Topic.find(params[:id].to_i)
          @name = @topic.name
          @levelName = params[:levelName]
          session[:id] = params[:id]
          session[:levelName] = params[:levelName]
          current_user.prepareQuestions(@topic.id, @levelName)
        rescue Exception => e
          puts e.message 
          render 'error'
        end
      end

      # This is the responder for all other responses, it updates the partial on the page.
      # When there are no more questions, log final score and redirect.
      format.js do
        # Is the user sending a response through? Check by searching for the forQuestion params
        # If so, log the outcome of the response
        if qid = params[:forQuestion] && Question.find(qid).respond(params[:userResponse])
          current_user.incrementCurrentScore
        end

        # Send the next question, if it exists
        if qID = current_user.sendQuestion
          @question = Question.find(qID)
          render 'respond.js'
          return
        end 

        # If it does not exist then log final score and send off to the db.
        if !current_user.inAdminMode || current_user.inRevisionMode
          if !current_user.hasFinishedQuestions(params[:id], params[:levelName])
            flash[:errorMessage] = 'Warning, could not save scores for previous level'
          else
            score = current_user.setScore(params[:id], params[:levelName])
            flash[:successMessage] = if score > User::THRESHOLD
              "Congratulations! You scored #{score}% so the next level is available."
            else 
              "You scored #{score}%."
            end
          end  
        else
          flash[:successMessage] = "Raw admin score: #{current_user.currentScore}"
        end

        render js: "window.location = 'topics/#{params[:id]}'"
      end 

    end 
  end 
end 