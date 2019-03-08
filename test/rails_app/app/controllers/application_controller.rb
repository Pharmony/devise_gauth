# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # protect_from_forgery
  if Rails.version >= '4'
    before_action :authenticate_user!
  else
    before_filter :authenticate_user!
  end
end
