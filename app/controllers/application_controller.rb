class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :preferred_language ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :preferred_language ])
  end

  private

  def set_locale
    I18n.locale = current_user&.preferred_language.presence_in(User::LANGUAGE_OPTIONS) || I18n.default_locale
  end
end
