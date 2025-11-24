OmniAuth.config.test_mode = true

RSpec.configure do |config|
  config.before do
    OmniAuth.config.mock_auth[:google_oauth2] = nil
    OmniAuth.config.mock_auth[:facebook] = nil
    OmniAuth.config.mock_auth[:twitter2] = nil
  end
end
