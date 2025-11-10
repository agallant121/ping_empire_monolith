class WebsitesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_website, only: %i[ show edit update destroy ]
  before_action :set_websites, only: %i[ new create ]

  def index
    @websites = current_user.websites
    @failed_websites_count = current_user.websites.with_failures_since(Time.current.beginning_of_day).count
    @websites = @websites.where("url ILIKE ?", "%#{params[:q]}%") if params[:q].present?
    @websites = @websites.recent.includes(:responses).page(params[:page]).per(12)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def failures
    @cutoff_time = Time.current.beginning_of_day
    scoped_websites = current_user.websites.with_failures_since(@cutoff_time)
    website_ids = scoped_websites.pluck(:id)
    @websites = current_user.websites.where(id: website_ids).order(:url)
    @failed_websites_count = website_ids.size

    if website_ids.empty?
      @failure_counts = Hash.new(0)
      @last_failure_at = {}
    else
      responses = Response.arel_table

      failure_stats = Response
                        .where(website_id: website_ids)
                        .where("responses.created_at >= ?", @cutoff_time)
                        .where("responses.status_code >= ? OR responses.error IS NOT NULL", 400)
                        .group(:website_id)
                        .select(
                          :website_id,
                          responses[:id].count.as("failure_count"),
                          responses[:created_at].maximum.as("last_failure_at")
                        )

      @failure_counts = Hash.new(0)
      @last_failure_at = {}

      failure_stats.each do |stat|
        @failure_counts[stat.website_id] = stat.failure_count
        @last_failure_at[stat.website_id] = stat.last_failure_at
      end
    end

    @failed_response_count = @failure_counts.values.sum
  end

  def show
    failures_cutoff = Time.current.beginning_of_day
    failed_scope = @website.responses
                               .where("status_code >= :min_status OR error IS NOT NULL", min_status: 400)
                               .where("created_at >= ?", failures_cutoff)

    @failed_responses_total = failed_scope.count
    @show_failed_only = params[:failed] == "true"

    scoped_responses = @show_failed_only ? failed_scope : @website.responses
    @responses = scoped_responses.order(created_at: :desc).page(params[:page]).per(15)

    @pagination_params = { format: :turbo_stream }
    @pagination_params[:failed] = "true" if @show_failed_only

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
