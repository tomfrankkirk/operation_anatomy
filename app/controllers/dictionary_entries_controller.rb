# frozen_string_literal: true

class DictionaryEntriesController < EndUserController
  def index
    @entries = DictionaryEntry.order(:title)
  end

  # Respond to remote JS requests to define a snippet
  # The DictionaryEntry.searchForEntry() method sanitises the string and checks combos. 
  # If no entry found returns an empty definition 
  # 
  # @param [String] searchString the string to attempt to define 
  # @return [JSON] hash { definition, title, example }, definition = '' to denote no entry 
  def define
    respond_to do |format|
      format.json do
        # Check the param searchString was successfully received.
        if string = params[:searchString]
          entry = DictionaryEntry.searchForEntry(string)
          if entry
            render json: { definition: entry.definition.downcase, title: entry.title.capitalize, example: entry.example.downcase }
            return
          end
        end

        # If not, return an empty hash
        render json: { definition: '' }
      end
    end
  end
end
