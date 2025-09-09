require "uri"

class Website < ApplicationRecord
  belongs_to :user

  has_many :responses, dependent: :destroy

  validates :url, presence: true, uniqueness: true,
                  format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must start with http:// or https://" },
                  uniqueness: { scope: :user_id, message: "has already been added for the current user" }
end
