require "rails_helper"

RSpec.describe SendFailureAlertsJob, type: :job do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { User.create!(email: "user@example.com", password: "password") }
  let!(:website) { user.websites.create!(url: "https://example.com") }
  let(:mailer_double) { instance_double(ActionMailer::MessageDelivery, deliver_now: true) }

  before do
    allow(FailureAlertMailer).to receive(:alert).and_return(mailer_double)
  end

  it "delivers an alert with the number of recent failures" do
    travel_to 1.hour.ago do
      website.responses.create!(status_code: 500, response_time: 123)
      website.responses.create!(status_code: 503, response_time: 200)
    end

    described_class.perform_now

    expect(FailureAlertMailer).to have_received(:alert).with(website, 2)
    expect(mailer_double).to have_received(:deliver_now)
  end

  it "ignores responses older than 24 hours" do
    travel_to 2.days.ago do
      website.responses.create!(status_code: 500, response_time: 123)
    end

    described_class.perform_now

    expect(FailureAlertMailer).not_to have_received(:alert)
  end

  it "ignores successful responses" do
    website.responses.create!(status_code: 200, response_time: 50)

    described_class.perform_now

    expect(FailureAlertMailer).not_to have_received(:alert)
  end
end
