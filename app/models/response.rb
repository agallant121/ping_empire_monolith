class Response < ApplicationRecord
  belongs_to :website
  after_create :check_for_failure

  validates :status_code, numericality: true, allow_nil: true
  validates :response_time, numericality: true, allow_nil: true

  scope :more_than_one_day_old, -> { where("created_at < ?", Time.current.beginning_of_day) }

  private

  def check_for_failure
    SendFailureAlertJob.perform_later(website, self) if status_code.to_i >= 400
  end
end
