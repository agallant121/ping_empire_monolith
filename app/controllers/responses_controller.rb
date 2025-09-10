class ResponsesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_website
  before_action :set_response, only: %i[ show edit update destroy ]

  def index
    @responses = @website.responses.page(params[:page]).per(10)
  end

  def show; end

  def new
    @response = @website.responses.new
  end

  def edit; end

  def create
    @response = @website.responses.new(response_params)

    respond_to do |format|
      if @response.save
        format.html { redirect_to [ @website, @response ], notice: "Response was successfully created." }
        format.json { render :show, status: :created, location: [ @website, @response ] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @response.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @response.update(response_params)
        format.html { redirect_to [ @website, @response ], notice: "Response was successfully updated." }
        format.json { render :show, status: :ok, location: [ @website, @response ] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @response.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @response.destroy!

    respond_to do |format|
      format.html { redirect_to website_responses_path(@website), status: :see_other, notice: "Response was successfully destroyed." }
      format.json { head :no_content }
    end
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
