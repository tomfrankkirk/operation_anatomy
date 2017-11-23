class SystemsController < EndUserController

   def index 
      @systems = System.all
      @systemNames = @systems.map { |s| s.name }
      @pathStubs = @systems.map { |s| '/' + s.id.to_s }
      @iconStubs = @systems.map { |s| s.shortName }
   end 

   def show 
      @system = System.find(params[:id])
      @topics = @system.topics
      @topicNames = @topics.map { |t| t.name }
      @pathStubs = @topics.map { |t| t.id.to_s }
      @iconStubs = @topics.map { |t| t.shortName }
      @path_root = topics_path + '/'
   end
   

end
