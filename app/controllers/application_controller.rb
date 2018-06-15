# frozen_string_literal: true

require 'browser'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def after_sign_in_path_for(_resource)
    systems_path
  end
end
