class PingAllWebsitesJob < ApplicationJob
  queue_as :default

  def perform(*args)

    ids = Rails.cache.read("website_ids") || []
    current_ids = Website.pluck(:id)

    current_ids_and_cached_ids_different = ids.sort != current_ids.sort

    if current_ids_and_cached_ids_different
      Rails.cache.write("website_ids", current_ids, expires_in: 12.hours)
      Rails.logger.info "Website list changed, updating cache"
      ids = current_ids
    else
      Rails.logger.info "Website list unchanged, using cached data"
    end

    ids.each do |website_id|
      PingWebsiteJob.perform_later(website_id)
    end
  end
end
