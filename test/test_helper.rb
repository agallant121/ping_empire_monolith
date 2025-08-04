ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    fixtures :all
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end

require "capybara/rails"
require "selenium/webdriver"
require "tmpdir"

Capybara.register_driver :selenium_chrome_headless_unique do |app|
  options = Selenium::WebDriver::Chrome::Options.new

  options.add_argument("--user-data-dir=#{Dir.mktmpdir("chrome-user-data")}")
  options.add_argument("--headless=new") # Use new headless mode if supported
  options.add_argument("--disable-gpu")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :selenium_chrome_headless_unique
