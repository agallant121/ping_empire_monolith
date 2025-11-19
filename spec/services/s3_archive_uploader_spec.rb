require "rails_helper"

describe S3ArchiveUploader do
  let(:credentials) do
    {
      bucket: "my-bucket",
      region: "us-east-1",
      access_key_id: "AKIA_TEST",
      secret_access_key: "super-secret",
      key_prefix: "daily"
    }
  end

  describe "#upload" do
    let(:uploader) { described_class.new(**credentials) }
    let(:file_path) { Rails.root.join("tmp", "responses.csv") }
    let(:http_double) { instance_double(Net::HTTP) }
    let(:timestamp) { Time.utc(2024, 1, 2, 12, 0, 0) }

    before do
      FileUtils.mkdir_p(file_path.dirname)
      File.write(file_path, "response data")
      allow(Time).to receive(:now).and_return(timestamp)
      allow(Net::HTTP).to receive(:new).and_return(http_double)
      allow(http_double).to receive(:use_ssl=)
      allow(http_double).to receive(:open_timeout=)
      allow(http_double).to receive(:read_timeout=)
    end

    after do
      FileUtils.rm_f(file_path)
      allow(Time).to receive(:now).and_call_original
    end

    it "sends a signed PUT request" do
      response = Net::HTTPOK.new("1.1", "200", "OK")
      allow(response).to receive(:body).and_return("ok")

      expect(http_double).to receive(:request) do |request|
        expect(request).to be_a(Net::HTTP::Put)
        expect(request["x-amz-date"]).to eq("20240102T120000Z")
        expect(request.path).to eq("/daily/responses.csv")
        expect(request["Authorization"]).to include("Credential=AKIA_TEST/20240102/us-east-1/s3/aws4_request")
        response
      end

      expect(uploader.upload(file_path)).to be(true)
    end

    it "returns false when S3 rejects the request" do
      response = Net::HTTPForbidden.new("1.1", "403", "Forbidden")
      allow(response).to receive(:body).and_return("forbidden")
      allow(http_double).to receive(:request).and_return(response)

      expect(uploader.upload(file_path)).to be(false)
    end

    it "raises an error when the file is missing" do
      File.delete(file_path)
      expect { uploader.upload(file_path) }.to raise_error(ArgumentError)
    end
  end
end
