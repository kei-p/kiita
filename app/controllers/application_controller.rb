class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def unauthorized
    message = '権限がありません'
    redirect_to :back, alert: message
  rescue ActionController::RedirectBackError
    redirect_to top_path, alert: message
  end

  def after_sign_in_path_for(resource)
    top_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys:[:name, :icon_url])
  end
end
