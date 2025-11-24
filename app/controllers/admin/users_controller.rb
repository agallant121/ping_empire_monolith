module Admin
  class UsersController < BaseController
    before_action :require_supervisor!

    def index
      @user = User.new
      @users = User.order(created_at: :desc)
    end

    def create
      @user = User.new(new_user_params)

      if @user.save
        redirect_to admin_users_path, notice: t("admin.users.flash.create.success")
      else
        @users = User.order(created_at: :desc)
        flash.now[:alert] = t("admin.users.flash.create.failure")
        render :index, status: :unprocessable_entity
      end
    end

    def destroy
      user = User.find(params[:id])

      message_key = if user == current_user
                      "self"
      elsif user.supervisor?
                      "supervisor_blocked"
      end

      if message_key
        redirect_to admin_users_path, alert: t("admin.users.flash.destroy.#{message_key}")
      else
        user.destroy
        redirect_to admin_users_path, notice: t("admin.users.flash.destroy.success")
      end
    end

    def update
      user = User.find(params[:id])

      if user.supervisor?
        redirect_to admin_users_path, alert: t("admin.users.flash.update.supervisor_blocked")
        return
      end

      role = role_param

      if role.blank?
        redirect_to admin_users_path, alert: t("admin.users.flash.update.invalid_role")
      elsif user.update(role: role)
        redirect_to admin_users_path, notice: t("admin.users.flash.update.success", email: user.email)
      else
        redirect_to admin_users_path, alert: t("admin.users.flash.update.failure")
      end
    end

    private

    def require_supervisor!
      return if current_user&.supervisor?

      redirect_to(root_path, alert: t("admin.users.not_authorized"))
    end

    def new_user_params
      params.require(:user).permit(:email, :role).tap do |attrs|
        attrs[:role] = attrs[:role].presence_in(allowed_roles) || "user"
        attrs[:password] = Devise.friendly_token[0, 20]
      end
    end

    def role_param
      params.require(:user).permit(:role)[:role].presence_in(allowed_roles)
    end

    def allowed_roles
      User.roles.except("supervisor").keys
    end
  end
end
