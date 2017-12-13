class DictionaryEntriesController < EndUserController

   def index 
      @entries = DictionaryEntry.order(:title)
   end 

   def define
      respond_to do |format|
         format.json { 

            # Check the param searchString was successfully received. 
            if string = params[:searchString]
               entry = DictionaryEntry.searchForEntry(string)
               if entry 
                     render :json => { :definition => entry.definition.downcase, :title => entry.title.capitalize, :example => entry.example.downcase }
                     return 
               end 
            end 

            # If not, return an empty hash 
            render :json => { :definition => "" }     
         }
      end
   end 


end
