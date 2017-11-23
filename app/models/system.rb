class System < ApplicationRecord
   has_many :topics
   serialize :level_names, Array    

   def shortNameForLevel(k)
      long = self.level_names 
      return long.split[0]
   end 

   def shortLevelNames 
      longs = self.level_names 
      return longs.map { |s| s.split[0].downcase }
   end 

   def shortName
      return self.name.split[0].downcase 
   end 
   
end
