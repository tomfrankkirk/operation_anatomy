class SystemsController < ApplicationController

   def index 
      @systems = System.all
   end 

   def show 
      @system = System.find(params[:id])
      @topics = @system.topics 
   end
   

end
