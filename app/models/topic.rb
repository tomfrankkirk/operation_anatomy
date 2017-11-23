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
      return System.find(self.system_id).shortLevelNames
   end 

    # Method to fetch shuffled array for all questions of a certain level within a topic. 
    # The IDs are then passed to a User, they will then fetch questions directly from 
    # the database by using each id as a key. 

    def fetchQuestionIDsForLevel(level)
        # fetch all questions for the level
        questionObjects = self.questions.where("level = ?", level)
        questionIDs = []
        # extract each question ID. 
        questionObjects.each do |q|
            questionIDs << q.id
        end
        questionIDs.shuffle
    end

    def numberOfQuestionsInLevel(level)
        return (self.questions.where("level = ?", level)).count
    end 

   
    def numberOfLevels
      s = System.find(self.system_id)
      return s.level_names.count
    end

    # Go hunting for the level names as a text file. If found, wipe the current ones
    # and then put in the latest ones. 
   #  def loadLevelNames
   #      path = Dir["teaching/#{self.name}/LevelNames.txt"]
   #      if path
   #          self.level_names = []
   #          File.open(path.first) { |f|
   #              lines = f.read
   #              lines = lines.split("\n")
   #              lines.each do |name|
   #                  self.level_names << name 
   #              end 
   #          }
   #          self.save
   #      end
   #  end

   #  def levelName(forLevel)
   #      if name = self.level_names[forLevel-1]
   #          return name 
   #      else
   #          return "Level #{forLevel}"
   #      end 
   #  end 

   def levelNames 
      return System.find(self.system_id).level_names 
   end 

end
