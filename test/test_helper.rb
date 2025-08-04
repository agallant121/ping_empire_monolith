ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
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
require "tmpdir"

Capybara.register_driver :selenium_chrome_headless_unique do |app|
  options = Selenium::WebDriver::Chrome::Options.new

  # ✅ Unique temp directory to prevent CI conflicts
  options.add_argument("--user-data-dir=#{Dir.mktmpdir("chrome-user-data")}")
  options.add_argument("--headless=new") # Use new headless mode if supported
  options.add_argument("--disable-gpu")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# ✅ Set as the default JavaScript driver
Capybara.javascript_driver = :selenium_chrome_headless_unique
