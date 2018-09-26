class ApplicationController < ActionController::Base
  include JSONAPI::ActsAsResourceController

  def context
    { current_user: current_user }
  end

  def current_user
    'Joe'
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
end
