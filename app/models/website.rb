require "uri"

class Website < ApplicationRecord
  after_commit :clear_website_ids_cache, on: [ :create, :destroy ]
  belongs_to :user

  has_many :responses, dependent: :destroy

  validates :url, presence: true,
                  format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must start with http:// or https://" },
                  uniqueness: { scope: :user_id, message: "has already been added for the current user" }

  scope :recent, -> { order(created_at: :desc) }

  def latest_response
    @latest_response ||= responses.order(created_at: :desc).first
  end

  def response_count
    @response_count ||= responses.count
  end

  def failed_responses_since_midnight?
    failed_response_count.positive? || response_error_count.positive?
  end

  def failed_response_count
    responses.where("status_code >= ? AND created_at >= ?", 400, Time.current.beginning_of_day).count
  end

  def response_error_count
    responses.where("error IS NOT NULL AND created_at >= ?", Time.current.beginning_of_day).count
  end

  private

  def clear_website_ids_cache
    Rails.cache.delete("website_ids_#{user_id}")
  end
end
