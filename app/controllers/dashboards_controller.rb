class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def show
    @websites = current_user.websites.recent.includes(:responses).page(params[:page]).per(12)
  end
end
