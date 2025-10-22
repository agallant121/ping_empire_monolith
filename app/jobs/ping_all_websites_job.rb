class PingAllWebsitesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    website_ids = Rails.cache.fetch("website_ids", expires_in: 12.hours) do
      ids = Website.pluck(:id)
      Rails.logger.info "Caching website list: #{ids.size} websites"
      ids
    end

    Rails.logger.info "Using cached website list (#{website_ids.size} websites)"

    website_ids.each do |website_id|
      PingWebsiteJob.perform_later(website_id)
    end
  end
end
