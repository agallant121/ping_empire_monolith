require "rails_helper"

RSpec.describe "Websites", type: :request do
  let(:user) { User.create!(email: "user@example.com", password: "password") }
  let(:other_user) { User.create!(email: "other@example.com", password: "password") }
  let!(:website) { user.websites.create!(url: "https://example.com") }
  let!(:other_website) { other_user.websites.create!(url: "https://other.com") }

  describe "GET /websites/:id" do
    it "allows access to own website" do
      sign_in user
      get website_path(website)
      expect(response).to have_http_status(:ok)
    end

    it "denies access to another user's website" do
      sign_in user
      expect {
        get website_path(other_website)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
