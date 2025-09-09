class FailureAlertMailer < ApplicationMailer
  def alert(website, failure_count)
    @website = website
    @failure_count = failure_count

    mail(
      to: @website.user.email,
      subject: "Ping Empire Alert: #{@failure_count} failures in the past 24 hours for #{@website.url}"
    )
  end
end
