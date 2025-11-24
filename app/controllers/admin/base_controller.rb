module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!

    private

    def require_admin!
      return if current_user&.admin_area_access?

      redirect_to(root_path, alert: t("admin.base.not_authorized"))
    end
  end
end
