require "rails_helper"

RSpec.describe "Admin::AwsSettings", type: :request do
  let(:admin) { User.create!(email: "admin@example.com", password: "Password1!", role: 1) }

  def sign_in_as(user)
    sign_in user, scope: :user
  end

  describe "GET /admin/aws_settings" do
    it "shows the form" do
      sign_in_as admin

      get admin_aws_settings_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("AWS Archive Settings")
    end
  end

  describe "POST /admin/aws_settings" do
    it "creates a new setting" do
      sign_in_as admin

      post admin_aws_settings_path, params: {
        aws_archive_setting: {
          access_key_id: "AKIA123",
          secret_access_key: "secret",
          region: "us-east-1",
          bucket: "my-bucket"
        }
      }

      expect(response).to redirect_to(admin_aws_settings_path)
      follow_redirect!
      expect(response.body).to include("AWS credentials saved")
      expect(AwsArchiveSetting.count).to eq(1)
    end
  end

  describe "PATCH /admin/aws_settings" do
    it "updates an existing record" do
      setting = AwsArchiveSetting.create!(access_key_id: "AKIA", secret_access_key: "secret", region: "us-east-1", bucket: "one")
      sign_in_as admin

      patch admin_aws_settings_path, params: {
        aws_archive_setting: {
          access_key_id: "AKIA456",
          secret_access_key: "secret",
          region: "us-east-2",
          bucket: "two"
        }
      }

      expect(response).to redirect_to(admin_aws_settings_path)
      expect(setting.reload.region).to eq("us-east-2")
      expect(setting.access_key_id).to eq("AKIA456")
    end
  end
end
