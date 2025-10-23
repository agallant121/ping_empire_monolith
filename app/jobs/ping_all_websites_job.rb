class PingAllWebsitesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    User.find_each do |user|
      cache_key = "website_ids_user_#{user.id}"

      ids = Rails.cache.read(cache_key) || []
      current_ids = user.websites.pluck(:id)

      current_ids_and_cached_ids_different = ids.sort != current_ids.sort

      if current_ids_and_cached_ids_different
        Rails.cache.write(cache_key, current_ids, expires_in: 12.hours)
        Rails.logger.info "Website list changed for user #{user.id}, updating cache"
        ids = current_ids
      else
        Rails.logger.info "Website list unchanged for user #{user.id}, using cached data"
      end

      ids.each do |website_id|
        PingWebsiteJob.perform_later(website_id)
      end
    end
  end
end
