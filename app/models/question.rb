# frozen_string_literal: true

class Question < ApplicationRecord
  serialize :possibleSolutions
  belongs_to :topic

  def respond(userResponse)
    userResponse == possibleSolutions[0]
  end

  def shuffledSolutions
    possibleSolutions.shuffle
  end

  def qID
    topicName = Topic.find(topic_id).name
    topicName + "L#{level}Q#{number}"
  end

  def solution
    possibleSolutions.first
  end
end
