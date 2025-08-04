ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    fixtures :all
  end
end

# Enable Devise helpers in integration (request) tests
class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end

# ✅ Capybara system test setup with unique Chrome user data directory
require "capybara/rails"
require "selenium/webdriver"
require "securerandom"

Capybara.register_driver :chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  unique_dir = "/tmp/chrome-user-data-#{SecureRandom.hex(8)}"
  options.add_argument("--user-data-dir=#{unique_dir}")
  options.add_argument("--headless") # remove this line if you want GUI
  options.add_argument("--disable-gpu")
  options.add_argument("--no-sandbox")

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :chrome
