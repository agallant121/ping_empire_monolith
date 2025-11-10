require "rails_helper"

RSpec.describe PingWebsiteJob, type: :job do
  let(:website) { Website.create!(url: "https://example.com") }

  it "creates a response record when the request succeeds" do
    fake_response = instance_double(Net::HTTPOK, code: "200")
    allow(Net::HTTP).to receive(:get_response).and_return(fake_response)

    expect {
      PingWebsiteJob.perform_now(website.id)
    }.to change(Response, :count).by(1)

    record = Response.last
    expect(record.website).to eq(website)
    expect(record.status_code).to eq(200)
    expect(record.error).to be_nil
  end

  it "captures the error message when the request fails" do
    allow(Net::HTTP).to receive(:get_response).and_raise(StandardError.new("boom"))

    expect {
      PingWebsiteJob.perform_now(website.id)
    }.to change(Response, :count).by(1)

    record = Response.last
    expect(record.website).to eq(website)
    expect(record.status_code).to be_nil
    expect(record.error).to eq("boom")
  end
end
