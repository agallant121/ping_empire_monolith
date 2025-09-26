# app/controllers/users/omniauth_callbacks_controller.rb
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    handle_auth "Google"
  end

  def facebook
    handle_auth "Facebook"
  end

  def twitter2
    handle_auth "Twitter"
  end

  private

  def handle_auth(kind)
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: kind) if is_navigational_format?
    else
      session["devise.auth_data"] = request.env["omniauth.auth"].except(:extra)
      redirect_to new_user_session_path, alert: "There was a problem signing you in through #{kind}."
    end
  end
end
