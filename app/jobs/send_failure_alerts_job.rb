class SendFailureAlertsJob < ApplicationJob
  queue_as :default

  def perform
    Website.includes(:user, :responses).find_each do |website|
      failure_count = website.responses
        .where("created_at >= ? AND status_code >= 400", 24.hours.ago)
        .count

      if failure_count > 0
        FailureAlertMailer.alert(website, failure_count).deliver_now
      end
    end
  end
end
