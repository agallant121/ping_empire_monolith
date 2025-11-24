require "rails_helper"

RSpec.describe "Admin::Dashboard", type: :request do
  let(:admin) { User.create!(email: "admin@example.com", password: "Password1!", role: 1) }

  def sign_in_as(user)
    sign_in user, scope: :user
  end

  describe "GET /admin" do
    it "shows a summary for admins" do
      sign_in_as admin
      other_user = User.create!(email: "user@example.com", password: "Password1!", role: 0)

      Website.create!(url: "https://example.com", user: admin)
      site_with_issue = Website.create!(url: "https://failing.test", user: other_user)
      Response.create!(website: site_with_issue, status_code: 500, response_time: 123, created_at: Time.current)

      get admin_root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Admin dashboard")
      expect(response.body).to include("2")
      expect(response.body).to include("Sites with incidents today")
    end

    it "redirects non-admins" do
      user = User.create!(email: "user@example.com", password: "Password1!", role: 0)
      sign_in_as user

      get admin_root_path

      expect(response).to redirect_to(root_path)
    end
  end
end
