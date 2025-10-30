class WebsitesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_website, only: %i[ show edit update destroy ]
  before_action :set_websites, only: %i[ new create ]

  def index
    @websites = current_user.websites
    @websites = @websites.where("url ILIKE ?", "%#{params[:q]}%") if params[:q].present?
    @websites = @websites.recent.includes(:responses).page(params[:page]).per(12)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    @responses = @website.responses.order(created_at: :desc).page(params[:page]).per(15)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def new
    @website = Website.new

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def edit
  end

  def create
    @website = current_user.websites.new(website_params)

    if @website.save
      redirect_to @website, notice: "Website was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @website.update(website_params)
      redirect_to @website, notice: "Website was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @website.destroy!
    redirect_to root_path, status: :see_other, alert: "Website was successfully destroyed."
  end

  private

  def set_website
    @website = current_user.websites.find(params[:id])
  end

  def set_websites
    @websites = current_user.websites.recent.page(params[:page]).per(9)
  end

  def website_params
    params.require(:website).permit(:url)
  end
end
