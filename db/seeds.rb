# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

# If no users exist, create one
if User.all == []
    User.create(email: "tomfrankkirk@gmail.com", password: "password", isAdmin: true)
    User.create(email: "christopher.horton@gtc.ox.ac.uk", password: "AnatomicalWalkthrough")
end

# Delete all questions to reseed them
# Don't delete topics - we need to keep this to keep the ids. 
Question.delete_all
# Seeding topics now. 
# shoulderTopic = Topic.create(name: "Shoulder", display_name: "The Shoulder Joint")

# Load the level names in. Each topic directory should have a document named LevelNames.txt at the top level. 
Topic.all.each do |t|
    t.loadLevelNames
end

# Seeding questions
File.open(Dir['teaching/questionSeed.rb'].first) { |file| load(file) }

# Wipe and then seed the dictionary definitions. Correct as of 18 March 2017.
DictionaryEntry.all.each do |e|
    e.destroy
end 

# Level names for each topic. 
File.open(Dir['teaching/JSDict.rb'].first) { |file| load(file) }

