require "rails_helper"

RSpec.describe Website, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { User.create!(email: "user@example.com", password: "password") }

  describe "validations" do
    it "requires a url" do
      website = described_class.new(user:, url: nil)

      expect(website).not_to be_valid
      expect(website.errors[:url]).to include("can't be blank")
    end

    it "requires a properly formatted url" do
      website = described_class.new(user:, url: "example.com")

      expect(website).not_to be_valid
      expect(website.errors[:url]).to include("must start with http:// or https://")
    end

    it "enforces uniqueness per user" do
      described_class.create!(user:, url: "https://example.com")
      duplicate = described_class.new(user:, url: "https://example.com")

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:url]).to include("has already been added for the current user")
    end
  end

  describe "associations" do
    it "destroys dependent responses" do
      website = described_class.create!(user:, url: "https://example.com")
      website.responses.create!(status_code: 200, response_time: 100)

      expect { website.destroy! }.to change { Response.count }.by(-1)
    end
  end

  describe "scopes" do
    it "orders recent websites with the newest first" do
      older = described_class.create!(user:, url: "https://old.com")
      newer = travel_to 1.minute.from_now do
        described_class.create!(user:, url: "https://new.com")
      end

      expect(described_class.recent).to eq([ newer, older ])
    end

    it "returns websites with failures since the provided timestamp" do
      cutoff = Time.current.beginning_of_day
      matching = described_class.create!(user:, url: "https://failing.com")
      other = described_class.create!(user:, url: "https://healthy.com")

      travel_to cutoff + 1.hour do
        matching.responses.create!(status_code: 500, response_time: 100)
        other.responses.create!(status_code: 200, response_time: 100)
      end

      expect(described_class.with_failures_since(cutoff)).to contain_exactly(matching)
    end
  end

  describe "instance methods" do
    it "returns the latest response" do
      website = described_class.create!(user:, url: "https://example.com")
      website.responses.create!(status_code: 200, response_time: 100)
      latest = travel_to 1.minute.from_now do
        website.responses.create!(status_code: 500, response_time: 100)
      end

      expect(website.latest_response).to eq(latest)
      expect(website.response_count).to eq(2)
    end

    it "reports when failures have occurred since midnight" do
      website = described_class.create!(user:, url: "https://example.com")
      travel_to Time.current.beginning_of_day + 1.hour do
        website.responses.create!(status_code: 500, response_time: 100)
      end

      expect(website.failed_responses_since_midnight?).to be(true)
      expect(website.failed_response_count).to eq(1)
    end

    it "reports when errors have occurred since midnight" do
      website = described_class.create!(user:, url: "https://example.com")
      travel_to Time.current.beginning_of_day + 2.hours do
        website.responses.create!(status_code: 200, response_time: 100, error: "Timeout")
      end

      expect(website.failed_responses_since_midnight?).to be(true)
      expect(website.response_error_count).to eq(1)
    end

    it "returns false when there are no recent failures or errors" do
      website = described_class.create!(user:, url: "https://example.com")

      expect(website.failed_responses_since_midnight?).to be(false)
      expect(website.failed_response_count).to eq(0)
      expect(website.response_error_count).to eq(0)
    end
  end
end
