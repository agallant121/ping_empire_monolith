class Users::PasswordsController < Devise::PasswordsController
  skip_before_action :require_no_authentication, if: :reset_password_token_present?

  def update
    super do |resource|
      bypass_sign_in(resource) if resource.errors.empty?
    end
  end

  def after_resetting_password_path_for(_resource)
    flash[:notice] = I18n.t("devise.passwords.updated_short")
    profile_path
  end

  private

  def reset_password_token_present?
    params[:reset_password_token].present? || params.dig(resource_name, :reset_password_token).present?
  end
end
