class DictionaryEntry < ApplicationRecord

    def self.searchForEntry(wordToDefine)

        # First, tidy up the input string, starting at the front. Remove whitespace or full stops.
        while wordToDefine[0] == "." || wordToDefine[0] == " " || wordToDefine[0] == "-" 
            wordToDefine = wordToDefine[1, wordToDefine.length]
        end 
        
        # Now, tidy from the back.
        while wordToDefine[wordToDefine.length] == "." || wordToDefine[wordToDefine.length] == " " || wordToDefine[wordToDefine.length] == "-"
            wordToDefine = wordToDefine[0, wordToDefine.length - 1]
        end 
        
        # Make lower case for case-insensitive comparison
        wordToDefine = wordToDefine.downcase
        
        # Entry may or may not have a hyphen - test either end, but only if entry has not yet been found.
        entry = DictionaryEntry.find_by(title: wordToDefine)

        if !entry 
            entry = DictionaryEntry.find_by(title: wordToDefine + "-")
        end 
        
        if !entry 
            entry = DictionaryEntry.find_by(title: "-" + wordToDefine)
        end 
        
        # The input string may be too large: if it contains whitespace, split down and trial the parts.
        # Maximum number of splits allowed is 4, to prevent entire paragraphs being fed in.
        if entry
            substrings = wordToDefine.split(" ", 4);
            successfulKey = "";
            while !entry && substrings.length != 0
                successfulKey = substrings.pop
                entry = DictionaryEntry.find_by(title: "-" + wordToDefine)
            end 
        end        
        return entry 
    end 

end
