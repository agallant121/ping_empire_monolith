require "rails_helper"

RSpec.describe PingAllWebsitesJob, type: :job do
  let!(:website1) { Website.create!(url: "https://google.com") }
  let!(:website2) { Website.create!(url: "https://yahoo.com") }

  it "enqueues PingWebsiteJob for each website" do
    expect {
      PingAllWebsitesJob.perform_now
    }.to have_enqueued_job(PingWebsiteJob).with(website1.id)
      .and have_enqueued_job(PingWebsiteJob).with(website2.id)
  end
end
