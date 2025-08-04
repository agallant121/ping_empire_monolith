require "net/http"
require "uri"

class PingWebsiteJob < ApplicationJob
  queue_as :default

  def perform(website_id)
    website = Website.find(website_id)
    return unless website

    uri = URI.parse(website.url)
    start_time= Time.now

    begin
      response = Net::HTTP.get_response(uri)
      end_time = Time.now
      status_code = response.code.to_i
      error = nil
    rescue => e
      status_code = nil
      end_time = Time.now
      error = e.message
    end

    response_time = ((end_time - start_time) * 1000).to_i

    website.responses.create!(
      status_code: status_code,
      response_time: response_time,
      error: error
    )
  end
end
