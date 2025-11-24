require 'rails_helper'
require 'securerandom'

RSpec.describe "Users::OmniauthCallbacks", type: :request do
  def stub_provider(provider, email: "social@example.com", uid: SecureRandom.uuid)
    auth_hash = OmniAuth::AuthHash.new(provider: provider, uid: uid, info: { email: email })
    OmniAuth.config.mock_auth[provider] = auth_hash
    Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
    Rails.application.env_config["omniauth.auth"] = auth_hash
  end

  shared_examples "successful oauth sign in" do |provider, route_helper|
    it "authenticates with #{provider}" do
      stub_provider(provider)

      expect { get send(route_helper) }.to change(User, :count).by(1)

      expect(response).to redirect_to(root_path)
      expect(session["warden.user.user.key"]).to be_present
      expect(User.last.provider).to eq(provider.to_s)
    end
  end

  include_examples "successful oauth sign in", :google_oauth2, :user_google_oauth2_omniauth_callback_path
  include_examples "successful oauth sign in", :facebook, :user_facebook_omniauth_callback_path
  include_examples "successful oauth sign in", :twitter2, :user_twitter2_omniauth_callback_path

  it "links to an existing user when the email matches" do
    user = User.create!(email: "linked@example.com", password: "password123")
    stub_provider(:facebook, email: user.email, uid: "facebook-uid")

    expect { get user_facebook_omniauth_callback_path }.not_to change(User, :count)

    user.reload
    expect(user.provider).to eq("facebook")
    expect(user.uid).to eq("facebook-uid")
  end
end
