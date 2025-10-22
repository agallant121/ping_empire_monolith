class Response < ApplicationRecord
  belongs_to :website
  after_create :check_for_failure, :check_for_error

  validates :status_code, numericality: true, allow_nil: true
  validates :response_time, numericality: true, allow_nil: true

  scope :more_than_one_day_old, -> { where("created_at < ?", Time.current.beginning_of_day) }

  def error_present?
    error.present?
  end

  def bad_status?
    status_code.to_i >= 400
  end

  private

  def check_for_failure
    SendFailureAlertJob.perform_later(website, self) if status_code.to_i >= 400
  end

  def check_for_error
    SendFailureAlertJob.perform_later(website, self) if error.present?
  end
end
