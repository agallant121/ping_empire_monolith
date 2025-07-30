class Response < ApplicationRecord
  belongs_to :website

  validates :status_code, numericality: true, allow_nil: true
  validates :response_time, numericality: true, allow_nil: true

  scope :more_than_one_day_old, -> { where("created_at < ?", 1.day.ago) }
end
