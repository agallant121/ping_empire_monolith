require "rails_helper"

RSpec.describe "Responses", type: :request do
  let(:user) { User.create!(email: "user@example.com", password: "password") }
  let(:website) { user.websites.create!(url: "https://example.com") }
  let!(:response_record) { website.responses.create!(status_code: 200, response_time: 100) }
  let(:other_user) { User.create!(email: "other@example.com", password: "password") }
  let(:other_website) { other_user.websites.create!(url: "https://other.com") }

  before { sign_in(user, scope: :user) }

  describe "GET /websites/:website_id/responses" do
    it "lists responses for the current user's website" do
      get website_responses_path(website)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(response_record.status_code.to_s)
    end

    it "denies access to another user's website" do
      get website_responses_path(other_website)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /websites/:website_id/responses" do
    it "creates a response" do
      expect do
        post website_responses_path(website), params: { response: { status_code: 500, response_time: 250, error: "Timeout" } }
      end.to change { website.responses.count }.by(1)

      expect(response).to redirect_to(website_response_path(website, Response.last))
      follow_redirect!
      expect(response.body).to include("Response was successfully created")
    end

    it "renders errors for invalid responses" do
      post website_responses_path(website), params: { response: { status_code: "bad", response_time: "slow" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("is not a number")
    end
  end

  describe "PATCH /websites/:website_id/responses/:id" do
    it "updates the response" do
      patch website_response_path(website, response_record), params: { response: { status_code: 201 } }

      expect(response).to redirect_to(website_response_path(website, response_record))
      follow_redirect!
      expect(response.body).to include("Response was successfully updated")
      expect(response_record.reload.status_code).to eq(201)
    end

    it "renders errors for invalid updates" do
      patch website_response_path(website, response_record), params: { response: { status_code: "bad" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("is not a number")
    end
  end

  describe "DELETE /websites/:website_id/responses/:id" do
    it "destroys the response" do
      expect do
        delete website_response_path(website, response_record)
      end.to change { website.responses.count }.by(-1)

      expect(response).to redirect_to(website_responses_path(website))
      follow_redirect!
      expect(response.body).to include("Response was successfully destroyed")
    end
  end
end
