class PingAllWebsitesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Website.find_each do |website|
      PingWebsiteJob.perform_later(website.id)
    end
  end
  
end
