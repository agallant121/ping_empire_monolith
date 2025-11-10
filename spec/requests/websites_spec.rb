require "rails_helper"

RSpec.describe "Websites", type: :request do
  let(:user) { User.create!(email: "user@example.com", password: "password") }
  let(:other_user) { User.create!(email: "other@example.com", password: "password") }
  let!(:website) { user.websites.create!(url: "https://example.com") }
  let!(:other_website) { other_user.websites.create!(url: "https://other.com") }

  before do
    sign_in user
  end

  describe "GET /websites" do
    it "lists the signed-in user's websites" do
      get websites_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(website.url)
      expect(response.body).not_to include(other_website.url)
    end
  end

  describe "POST /websites" do
    it "creates a website" do
      expect {
        post websites_path, params: { website: { url: "https://new-site.test" } }
      }.to change { user.websites.count }.by(1)

      created_site = user.websites.order(:created_at).last
      expect(response).to redirect_to(website_path(created_site))
    end
  end

  describe "PATCH /websites/:id" do
    it "updates the website url" do
      patch website_path(website), params: { website: { url: "https://updated.example" } }

      expect(response).to redirect_to(website_path(website))
      expect(website.reload.url).to eq("https://updated.example")
    end
  end

  describe "DELETE /websites/:id" do
    it "removes the website" do
      expect {
        delete website_path(website)
      }.to change { user.websites.count }.by(-1)

      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /websites/:id" do
    it "allows access to own website" do
      get website_path(website)
      expect(response).to have_http_status(:ok)
    end

    it "denies access to another user's website" do
      expect {
        get website_path(other_website)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
