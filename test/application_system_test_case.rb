require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]

  include Warden::Test::Helpers

  setup do
    Warden.test_mode!
  end

  teardown do
    Warden.test_reset!
  end

  def sign_in(user)
    login_as(user, scope: :user)
  end
end
