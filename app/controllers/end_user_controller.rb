# frozen_string_literal: true

class EndUserController < ApplicationController
  before_action :authenticate_user!
end
