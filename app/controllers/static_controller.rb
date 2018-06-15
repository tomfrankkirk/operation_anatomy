# frozen_string_literal: true

class StaticController < ApplicationController
  # A controller to handle the various static pages in the app.
  def index; end

  def about; end

  def help; end

  def bugs
    @bugs = FeedbackRecord.where('tone = ?', 'Bug')
    @bugs = @bugs.order(:created_at)
  end

  def tech; end
end
