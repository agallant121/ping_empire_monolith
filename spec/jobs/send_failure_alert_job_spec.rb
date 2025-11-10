require "rails_helper"

RSpec.describe SendFailureAlertJob, type: :job do
  let(:user) { User.create!(email: "user@example.com", password: "password") }
  let(:website) { user.websites.create!(url: "https://example.com") }
  let(:response) { website.responses.create!(status_code: 500, response_time: 100) }
  let(:mailer_double) { instance_double(ActionMailer::MessageDelivery, deliver_now: true) }

  before do
    allow(NotificationMailer).to receive(:failure_alert).and_return(mailer_double)
  end

  it "delivers a failure alert when a user is present" do
    described_class.perform_now(website, response)

    expect(NotificationMailer).to have_received(:failure_alert).with(user, website, response)
    expect(mailer_double).to have_received(:deliver_now)
  end

  it "does not deliver a failure alert when the website has no user" do
    described_class.perform_now(double("Website", user: nil), response)

    expect(NotificationMailer).not_to have_received(:failure_alert)
  end
end
