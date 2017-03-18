class DictionaryEntriesController < EndUserController
    def index 
        @entries = DictionaryEntry.order(:title)
    end 
end
