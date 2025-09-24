require "uri"

class Website < ApplicationRecord
  belongs_to :user

  has_many :responses, dependent: :destroy

  validates :url, presence: true,
                  format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must start with http:// or https://" },
                  uniqueness: { scope: :user_id, message: "has already been added for the current user" }

  scope :recent, -> { order(created_at: :desc) }

  def latest_response
    @latest_response ||= responses.order(created_at: :desc).first
  end
end
