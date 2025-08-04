class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def show
    @websites = current_user.websites.includes(:responses)
  end
end
