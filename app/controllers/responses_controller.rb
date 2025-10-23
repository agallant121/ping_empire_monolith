class ResponsesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_website
  before_action :set_response, only: %i[ show edit update destroy ]

  def index
    @responses = @website.responses.page(params[:page]).per(10)
  end

  def show
  end

  def new
    @response = @website.responses.new
  end

  def edit
  end

  def create
    @response = @website.responses.new(response_params)

    if @response.save
      redirect_to [@website, @response], notice: "Response was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @response.update(response_params)
      redirect_to [@website, @response], notice: "Response was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @response.destroy!
    redirect_to website_responses_path(@website), status: :see_other, notice: "Response was successfully destroyed."
  end

  private

  def set_response
    @response = @website.responses.find(params[:id])
  end

  def response_params
    params.require(:response).permit(:status_code, :response_time, :error)
  end

  def set_website
    @website = current_user.websites.find(params[:website_id])
  end
end