class ProfilesController < ApplicationController
  before_action :authenticate_user!

  helper_method :connected_provider?, :provider_title, :oauth_authorize_path

  def show; end

  def update
    if current_user.update(profile_params)
      redirect_to profile_path, notice: t("profiles.updated")
    else
      flash.now[:alert] = t("profiles.update_failed")
      render :show, status: :unprocessable_entity
    end
  end

  def send_reset_password
    current_user.send_reset_password_instructions
    redirect_to profile_path, notice: t("profiles.reset_sent")
  end

  def disconnect_oauth
    provider = params[:provider]

    if connected_provider?(provider)
      current_user.update(provider: nil, uid: nil)
      redirect_to profile_path, notice: t("profiles.oauth_disconnected", provider: provider_title(provider))
    else
      redirect_to profile_path, alert: t("profiles.oauth_not_connected")
    end
  end

  private

  def profile_params
    params.require(:user).permit(:email, :preferred_language)
  end

  def connected_provider?(provider)
    current_user.provider == provider
  end

  def provider_title(provider)
    {
      "google_oauth2" => "Google",
      "facebook" => "Facebook",
      "twitter2" => "Twitter"
    }[provider.to_s] || provider.to_s.titleize
  end

  def oauth_authorize_path(provider)
    send("user_#{provider}_omniauth_authorize_path")
  end
end
