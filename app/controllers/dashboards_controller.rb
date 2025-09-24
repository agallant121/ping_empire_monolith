class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def show
    @websites = current_user.websites
    @websites = @websites.where("url ILIKE ?", "%#{params[:q]}%") if params[:q].present?
    @websites = @websites.recent.includes(:responses).page(params[:page]).per(12)
  end
end
