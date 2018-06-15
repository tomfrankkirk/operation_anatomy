# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

# If no users exist, create one
User.create(email: 'tomfrankkirk@gmail.com', password: 'password', isAdmin: true)
# User.create(email: "christopher.horton@gtc.ox.ac.uk", password: "AnatomicalWalkthrough")

# Delete all questions to reseed them
Question.delete_all
Topic.delete_all
System.delete_all

# Seed systems
msk = System.create(name: 'Musculoskeletal')
msk.level_names = ['Introduction', 'Bones', 'Ligaments', 'Vasculature', 'Innervation', 'Movements', 'Muscles', 'Clinical Relevance']
msk.save

cv = System.create(name: 'Cardiovascular')
gi = System.create(name: 'Gastrointestinal')
hb = System.create(name: 'Hepatobiliary')
uro = System.create(name: 'Urogenital')
rs = System.create(name: 'Respiratory')
intro = System.create(name: 'Introduction to Anatomy')

# Seeding topics
shoulderTopic = Topic.create(name: 'The Shoulder Joint', system_id: msk.id)

# Seeding questions
File.open(Dir['teaching/questionSeed.rb'].first) { |file| load(file) }

# Wipe and then seed the dictionary definitions. Correct as of 18 March 2017.
DictionaryEntry.all.each(&:destroy)

# Level names for each topic.
File.open(Dir['teaching/JSDict.rb'].first) { |file| load(file) }
