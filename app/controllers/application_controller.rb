class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user
  before_filter :require_login
  config.serve_static_assets = true

  def valid_session_id
    User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

private 
  
  def require_login
    unless valid_session_id && current_user
      redirect_to login_path
    end
  end
end
