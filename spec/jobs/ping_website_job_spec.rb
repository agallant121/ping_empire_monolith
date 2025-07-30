require "rails_helper"
require "webmock/rspec"

RSpec.describe PingWebsiteJob, type: :job do
  before do
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  let(:website) { Website.create!(url: "https://example.com") }

  describe "#perform" do
    context "when the website is accessible and returns a 200 status" do
      before do
        stub_request(:get, website.url).to_return(status: 200, body: "OK")
      end

      it "creates a successful Response record" do
        expect {
          PingWebsiteJob.perform_now(website.id)
        }.to change(Response, :count).by(1)

        response = Response.last
        expect(response.website).to eq(website)
        expect(response.status_code).to eq(200)
        expect(response.response_time).to be_present
        expect(response.error).to eq(nil)
      end
    end

    context "when the website returns an error (404)" do
      before do
        stub_request(:get, website.url).to_return(status: 404, body: "Not Found")
      end

      it "creates a Response record with the error status" do
        expect {
          PingWebsiteJob.perform_now(website.id)
        }.to change(Response, :count).by(1)

        response = Response.last
        expect(response.website).to eq(website)
        expect(response.status_code).to eq(404)
        expect(response.response_time).to be_present
        expect(response.error).to eq(nil)
      end
    end

    context "when the website raises a network error" do
      before do
        stub_request(:get, website.url).to_raise(StandardError.new("Timeout"))
      end

      it "creates a Response record with an error message" do
        expect {
          PingWebsiteJob.perform_now(website.id)
        }.to change(Response, :count).by(1)

        response = Response.last
        expect(response.website).to eq(website)
        expect(response.status_code).to be_nil
        expect(response.response_time).to be_present
        expect(response.error).to eq("Timeout")
      end
    end
  end
end
