# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   topic = Topic.create([{ name: 'Shoulder' }])
#   Question.create(body: 'A question', topic: topic.first)

# delete all objects (note that questions depend on topic so will be destroyed)
User.delete_all
Topic.delete_all


User.create!(email: "tomfrankkirk@gmail.com", password: "password")
shoulderTopic = Topic.create(name: "Shoulder")

shoulderTopic.questions << Question.create(number: 1, level: 1, body: "Choose the right answer", solution: "Right", possibleSolutions: ["Right", "Wrong"])
shoulderTopic.questions << Question.create(number: 2, level: 1, body: "Choose the right answer", solution: "Right", possibleSolutions: ["Right", "Wrong"])
shoulderTopic.questions << Question.create(number: 3, level: 1, body: "Choose the right answer", solution: "Right", possibleSolutions: ["Right", "Wrong"])

shoulderTopic.questions << Question.create(number: 1, level: 2, body: "Choose the right answer", solution: "Right", possibleSolutions: ["Right", "Wrong"])
shoulderTopic.questions << Question.create(number: 2, level: 2, body: "Choose the right answer", solution: "Right", possibleSolutions: ["Right", "Wrong"])
shoulderTopic.questions << Question.create(number: 3, level: 2, body: "Choose the right answer", solution: "Right", possibleSolutions: ["Right", "Wrong"])

shoulderTopic.questions << Question.create(number: 1, level: 3, body: "Choose the right answer", solution: "Right", possibleSolutions: ["Right", "Wrong"])
shoulderTopic.questions << Question.create(number: 2, level: 3, body: "Choose the right answer", solution: "Right", possibleSolutions: ["Right", "Wrong"])
shoulderTopic.questions << Question.create(number: 3, level: 3, body: "Choose the right answer", solution: "Right", possibleSolutions: ["Right", "Wrong"])

