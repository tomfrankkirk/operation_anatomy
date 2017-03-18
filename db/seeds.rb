# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

# If no users exist, create one
if User.all == []
    User.create!(email: "tomfrankkirk@gmail.com", password: "password")
end

# Delete all topics to reseed them
Topic.delete_all
Question.delete_all

# Seeding topics now. 
shoulderTopic = Topic.create(name: "Shoulder", display_name: "The Shoulder Joint")

# Seeding questions
File.open(Dir['teaching/questionSeed.rb'].first) { |file| load(file) }

# Wipe and then seed the dictionary definitions. Correct as of 18 March 2017.
DictionaryEntry.all.each do |e|
    e.destroy
end 
File.open(Dir['teaching/JSDict.rb'].first) { |file| load(file) }
