class Response < ApplicationRecord
  belongs_to :website
  after_create :check_for_failure

  validates :status_code, numericality: true, allow_nil: true
  validates :response_time, numericality: true, allow_nil: true

  scope :more_than_one_day_old, -> { where("created_at < ?", Time.current.beginning_of_day) }

  private

  def check_for_failure
    if status_code >= 400
      SendFailureAlertJob.perform_later(website, self)
    end
  end
end
