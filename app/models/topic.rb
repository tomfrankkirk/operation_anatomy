class Topic < ApplicationRecord
    serialize :level_names, Array
    belongs_to :system
    has_many :questions, dependent: :destroy

   def shortName
      splits = self.name.downcase.split
      if splits[0] == "the"
         return splits[1]
      end 
      return splits[0]
   end 

   def shortLevelNames 
      sys = System.find(self.system_id)
      return sys.shortLevelNames
   end 

   def levelName(forLevel)
      return self.shortLevelNames[forLevel - 1]
   end

   def levelNumber(forName)
      return self.shortLevelNames.find_index(forName) + 1
   end 

   # Method to fetch shuffled array for all questions of a certain level within a topic. 
   # The IDs are then passed to a User, they will then fetch questions directly from 
   # the database by using each id as a key. 

   def fetchQuestionIDsForLevel(levelName)
      # fetch all questions for the level
      
      level = self.levelNumber(levelName)
      questionObjects = self.questions.where("level = ?", level)
      questionIDs = []
      # extract each question ID. 
      questionObjects.each do |q|
         questionIDs << q.id
      end
      questionIDs.shuffle
   end

   def numberOfQuestionsInLevel(levelName)
      return qs = self.fetchQuestionIDsForLevel(levelName).count 
   end 

   def numberOfLevels
      names = self.shortLevelNames
      return names.count 
   end

   def levelNames 
      return System.find(self.system_id).level_names 
   end 

end
