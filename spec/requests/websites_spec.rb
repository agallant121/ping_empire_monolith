require "rails_helper"

RSpec.describe "Websites", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { User.create!(email: "user@example.com", password: "password") }
  let(:other_user) { User.create!(email: "other@example.com", password: "password") }
  let!(:website) { user.websites.create!(url: "https://example.com") }
  let!(:other_website) { other_user.websites.create!(url: "https://other.com") }

  before { sign_in(user, scope: :user) }
  describe "GET /websites" do
    it "lists only the current user's websites" do
      get websites_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("https://example.com")
      expect(response.body).not_to include("https://other.com")
    end

    it "filters websites by the provided query" do
      user.websites.create!(url: "https://filter-me.com")

      get websites_path, params: { q: "filter" }

      expect(response.body).to include("https://filter-me.com")
      expect(response.body).not_to include("https://example.com")
    end
  end

  describe "GET /websites/failures" do
    it "shows only websites with recent failures" do
      failing = user.websites.create!(url: "https://failing.com")
      travel_to Time.current.beginning_of_day + 1.hour do
        failing.responses.create!(status_code: 500, response_time: 100)
        website.responses.create!(status_code: 200, response_time: 100)
      end

      get failures_websites_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("https://failing.com")
      expect(response.body).not_to include("https://example.com")
    end
  end

  describe "GET /websites/:id" do
    it "allows access to own website" do
      get website_path(website)
      expect(response).to have_http_status(:ok)
    end

    it "denies access to another user's website" do
      get website_path(other_website)

      expect(response).to have_http_status(:not_found)
    end

    it "shows only failed responses when requested" do
      successful = website.responses.create!(status_code: 200, response_time: 100)
      failing = website.responses.create!(status_code: 500, response_time: 100)

      get website_path(website, failed: true)

      expect(response.body).to include("table-danger")
      expect(response.body).to include(failing.status_code.to_s)
      expect(response.body).not_to include(successful.status_code.to_s)
    end
  end

  describe "POST /websites" do
    it "creates a website for the current user" do
      expect do
        post websites_path, params: { website: { url: "https://created.com" } }
      end.to change { user.websites.count }.by(1)

      expect(response).to redirect_to(website_path(Website.last))
      follow_redirect!
      expect(response.body).to include("Website was successfully created")
    end

    it "renders errors when the website is invalid" do
      post websites_path, params: { website: { url: "invalid" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("must start with http:// or https://")
    end
  end

  describe "PATCH /websites/:id" do
    it "updates the website when valid" do
      patch website_path(website), params: { website: { url: "https://updated.com" } }

      expect(response).to redirect_to(website_path(website))
      follow_redirect!
      expect(response.body).to include("Website was successfully updated")
      expect(website.reload.url).to eq("https://updated.com")
    end

    it "renders errors when the update is invalid" do
      patch website_path(website), params: { website: { url: "invalid" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("must start with http:// or https://")
    end
  end

  describe "DELETE /websites/:id" do
    it "destroys the website" do
      expect do
        delete website_path(website)
      end.to change { user.websites.count }.by(-1)

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("Website was successfully destroyed")
    end

    it "shows only failed responses when requested" do
      successful = website.responses.create!(status_code: 200, response_time: 100)
      failing = website.responses.create!(status_code: 500, response_time: 100)

      get website_path(website, failed: true)

      expect(response.body).to include("table-danger")
      expect(response.body).to include(failing.status_code.to_s)
      expect(response.body).not_to include(successful.status_code.to_s)
    end
  end

  describe "POST /websites" do
    it "creates a website for the current user" do
      expect do
        post websites_path, params: { website: { url: "https://created.com" } }
      end.to change { user.websites.count }.by(1)

      expect(response).to redirect_to(website_path(Website.last))
      follow_redirect!
      expect(response.body).to include("Website was successfully created")
    end

    it "renders errors when the website is invalid" do
      post websites_path, params: { website: { url: "invalid" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("must start with http:// or https://")
    end
  end

  describe "PATCH /websites/:id" do
    it "updates the website when valid" do
      patch website_path(website), params: { website: { url: "https://updated.com" } }

      expect(response).to redirect_to(website_path(website))
      follow_redirect!
      expect(response.body).to include("Website was successfully updated")
      expect(website.reload.url).to eq("https://updated.com")
    end

    it "renders errors when the update is invalid" do
      patch website_path(website), params: { website: { url: "invalid" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("must start with http:// or https://")
    end
  end

  describe "DELETE /websites/:id" do
    it "destroys the website" do
      expect do
        delete website_path(website)
      end.to change { user.websites.count }.by(-1)

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("Website was successfully destroyed")
    end
  end
end
