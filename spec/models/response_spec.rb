require "rails_helper"

RSpec.describe Response, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { User.create!(email: "user@example.com", password: "password") }
  let(:website) { user.websites.create!(url: "https://example.com") }

  describe "validations" do
    it "allows nil status codes" do
      response = described_class.new(website:, status_code: nil, response_time: 100)

      expect(response).to be_valid
    end

    it "requires numerical status codes when present" do
      response = described_class.new(website:, status_code: "abc", response_time: 100)

      expect(response).not_to be_valid
      expect(response.errors[:status_code]).to be_present
    end

    it "allows nil response times" do
      response = described_class.new(website:, status_code: 200, response_time: nil)

      expect(response).to be_valid
    end

    it "requires numerical response times when present" do
      response = described_class.new(website:, status_code: 200, response_time: "slow")

      expect(response).not_to be_valid
      expect(response.errors[:response_time]).to be_present
    end
  end

  describe "more_than_one_day_old" do
    it "returns responses created before the beginning of the current day" do
      old_response = website.responses.create!(status_code: 200, response_time: 100, created_at: 2.days.ago)
      recent_response = website.responses.create!(status_code: 200, response_time: 100)

      expect(described_class.more_than_one_day_old).to eq([ old_response ])
      expect(described_class.more_than_one_day_old).not_to include(recent_response)
    end
  end

  describe "callbacks" do
    it "enqueues a failure alert job when the status code is 400 or greater" do
      expect do
        website.responses.create!(status_code: 500, response_time: 100)
      end.to have_enqueued_job(SendFailureAlertJob).with(website, kind_of(Response))
    end

    it "enqueues a failure alert job when an error is present" do
      expect do
        website.responses.create!(status_code: nil, response_time: 100, error: "Timeout")
      end.to have_enqueued_job(SendFailureAlertJob).with(website, kind_of(Response))
    end

    it "does not enqueue a failure alert job when the response is successful" do
      expect do
        website.responses.create!(status_code: 200, response_time: 100)
      end.not_to have_enqueued_job(SendFailureAlertJob)
    end
  end

  describe "instance methods" do
    it "identifies when an error is present" do
      response = website.responses.create!(status_code: 200, response_time: 100, error: "Timeout")

      expect(response.error_present?).to be(true)
    end

    it "identifies when an error is not present" do
      response = website.responses.create!(status_code: 200, response_time: 100)

      expect(response.error_present?).to be(false)
    end

    it "identifies bad status codes" do
      response = website.responses.create!(status_code: 500, response_time: 100)

      expect(response.bad_status?).to be(true)
    end

    it "identifies non-bad status codes" do
      response = website.responses.create!(status_code: 200, response_time: 100)

      expect(response.bad_status?).to be(false)
    end
  end
end
