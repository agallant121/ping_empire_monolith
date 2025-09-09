class NotificationMailer < ApplicationMailer
  default from: "no-reply@pingempire.com"

  def failure_alert(user, website, response)
    @user = user
    @website = website
    @response = response

    mail(to: @user.email, subject: "Ping Empire: Your website is down and not responding!")
  end
end
