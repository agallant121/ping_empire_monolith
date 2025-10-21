class WebsitesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_website, only: %i[ show edit update destroy ]
  before_action :set_websites, only: %i[ new create ]

  def index
    @websites = current_user.websites
  end

  def show
    @responses = @website.responses.order(created_at: :desc).page(params[:page]).per(15)
  end


  def new
    @website = Website.new
  end

  def edit
  end

  def create
    @website = current_user.websites.new(website_params)

    respond_to do |format|
      if @website.save
        format.html { redirect_to @website, notice: "Website was successfully created." }
        format.json { render :show, status: :created, location: @website }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @website.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @website.update(website_params)
        format.html { redirect_to @website, notice: "Website was successfully updated." }
        format.json { render :show, status: :ok, location: @website }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @website.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @website.destroy!

    respond_to do |format|
      format.html { redirect_to root_path, status: :see_other, notice: "Website was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

    def set_website
      @website = current_user.websites.find(params[:id])
    end

    def set_websites
      @websites = current_user.websites.recent.page(params[:page]).per(9)
    end

    def website_params
      params.expect(website: [ :url ])
    end
end
