class LanguagePreferencesController < ApplicationController
  before_action :authenticate_user!

  def update
    if current_user.update(preferred_language_params)
      flash[:notice] = t("language_preferences.updated", language: t("languages.#{current_user.preferred_language}"))
    else
      flash[:alert] = t("language_preferences.failed")
    end

    redirect_back fallback_location: root_path
  end

  private

  def preferred_language_params
    params.require(:user).permit(:preferred_language)
  end
end
