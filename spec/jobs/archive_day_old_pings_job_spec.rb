require "rails_helper"
require "csv"

RSpec.describe ArchiveDayOldPingsJob, type: :job do
  before do
    user =  User.create!(email: "user@example.com", password: "password")
    website = Website.create!(url: "https://google.com", user_id: user.id)
    Response.create!(
      website_id: website.id,
      status_code: 200,
      response_time: 123,
      created_at: 2.days.ago
    )

    website2 = Website.create!(url: "https://yahoo.com", user_id: user.id)
    Response.create!(
      website_id: website2.id,
      status_code: 200,
      response_time: 321,
      created_at: 1.hour.ago
    )
  end

  it "archives old responses into a CSV and deletes them from the DB" do
    expect(Response.count).to eq(2)

    ArchiveDayOldPingsJob.perform_now

    csv_file = Dir["archive/responses*.csv"].max_by { |f| File.mtime(f) }

    expect(csv_file).to be_present
    expect(File).to exist(csv_file)

    rows = CSV.read(csv_file, headers: true)

    expect(rows.headers).to eq([ "id", "website_id", "status_code", "response_time", "created_at" ])
    expect(rows.size).to eq(1)
    expect(rows[0]["status_code"]).to eq("200")

    expect(Response.count).to eq(1)
  end
end
