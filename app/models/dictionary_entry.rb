# frozen_string_literal: true

class DictionaryEntry < ApplicationRecord
  def self.searchForEntry(wordToDefine)
    # First, tidy up the input string, starting at the front. Remove whitespace or full stops.
    while wordToDefine[0] == '.' || wordToDefine[0] == ' ' || wordToDefine[0] == '-'
      wordToDefine = wordToDefine[1, wordToDefine.length]
    end

    # Now, tidy from the back.
    while wordToDefine[wordToDefine.length] == '.' || wordToDefine[wordToDefine.length] == ' ' || wordToDefine[wordToDefine.length] == '-'
      wordToDefine = wordToDefine[0, wordToDefine.length - 1]
    end

    # Make lower case for case-insensitive comparison
    wordToDefine = wordToDefine.downcase

    # Entry may or may not have a hyphen so wrap it up in wildcards.
    entry = DictionaryEntry.find_by('title LIKE ?', + wordToDefine)

    # The input string may be too large: if it contains whitespace, split down and trial the parts.
    # Maximum number of splits allowed is 2, to prevent entire paragraphs being fed in.
    unless entry
      substrings = wordToDefine.split(' ', 2)

      substrings.each do |sub|
        entry = DictionaryEntry.find_by('title LIKE ?', sub)
        break if entry
      end

      # One last try: if nothing, try combos of the substrings.
      if substrings[0] && substrings[1] && !entry
        entry = DictionaryEntry.find_by('title LIKE ?', substrings[0] + '%' + substrings[1])
      end

      if substrings[1] && substrings[2] && !entry
        entry = DictionaryEntry.find_by('title LIKE ?', substrings[1] + '%' + substrings[2])
      end

    end
    entry
  end
end
