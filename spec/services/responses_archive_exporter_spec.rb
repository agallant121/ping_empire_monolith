require "rails_helper"

RSpec.describe ResponsesArchiveExporter do
  subject(:exporter) { described_class.new }
  let(:user) { User.create!(email: "admin@example.com", password: "Password1!", role: 1) }
  let(:website) { Website.create!(url: "https://example.com", user: user) }

  before do
    Response.create!(website: website, status_code: 200, response_time: 100, created_at: 2.days.ago)
  end

  after do
    Dir.glob(Rails.root.join("archive", "responses*.csv")).each { |file| FileUtils.rm_f(file) }
  end

  it "saves responses locally" do
    result = exporter.call

    expect(result.status).to eq(:saved_locally)
    expect(result.file_path).to include("responses")
    expect(result.archived_count).to eq(1)
    expect(result.message).to include("Saved 1 responses")
    expect(Response.more_than_one_day_old).to be_empty
  end

  it "returns the file name" do
    result = exporter.call

    expect(result.file_name).to eq(File.basename(result.file_path))
    expect(File.exist?(result.file_path)).to be(true)
  end

  it "returns :no_data when there are no responses to archive" do
    Response.delete_all

    result = exporter.call

    expect(result.status).to eq(:no_data)
    expect(result.message).to include("No responses older than one day")
    expect(result.archived_count).to eq(0)
  end
end
