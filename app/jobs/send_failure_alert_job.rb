class SendFailureAlertJob < ApplicationJob
  queue_as :default

  def perform(website, response)
    user = website.user
    return unless user.present?

    NotificationMailer.failure_alert(user, website, response).deliver_now
  end
end
