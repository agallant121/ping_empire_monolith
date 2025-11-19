require "rails_helper"

RSpec.describe "Admin::Archives", type: :request do
  let(:admin) { User.create!(email: "admin@example.com", password: "Password1!", role: 1) }
  let(:archive_glob) { Rails.root.join("archive", "responses*.csv") }

  def sign_in_as(user)
    sign_in user, scope: :user
  end

  after do
    Dir.glob(archive_glob).each { |file| FileUtils.rm_f(file) }
  end

  describe "GET /admin/archives" do
    it "shows the archive dashboard to admins" do
      sign_in_as admin

      get admin_archives_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Response Archives")
    end

    it "redirects regular users" do
      user = User.create!(email: "user@example.com", password: "Password1!", role: 0)
      sign_in_as user

      get admin_archives_path

      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /admin/archives/export" do
    it "runs an export and shows a success message when AWS is not connected" do
      sign_in_as admin
      website = Website.create!(url: "https://example.com", user: admin)
      Response.create!(website: website, status_code: 200, response_time: 123, created_at: 2.days.ago)
      allow(ArchiveDayOldPingsJob).to receive(:build_s3_uploader).and_return(nil)

      post export_admin_archives_path

      expect(response).to redirect_to(admin_archives_path)
      follow_redirect!
      expect(response.body).to include("Saved 1 responses")
      expect(response.body).to include("Download it now")
    end

    it "shows a warning when there are no responses" do
      sign_in_as admin

      post export_admin_archives_path

      expect(response).to redirect_to(admin_archives_path)
      follow_redirect!
      expect(response.body).to include("No responses older than one day")
    end

    context "when AWS credentials are configured" do
      let(:uploader) { instance_double(S3ArchiveUploader) }

      before do
        allow(ArchiveDayOldPingsJob).to receive(:build_s3_uploader).and_return(uploader)
      end

      it "automatically uploads the generated CSV" do
        sign_in_as admin
        website = Website.create!(url: "https://example.com", user: admin)
        Response.create!(website: website, status_code: 200, response_time: 123, created_at: 2.days.ago)
        allow(uploader).to receive(:upload).and_return(true)

        post export_admin_archives_path

        expect(response).to redirect_to(admin_archives_path)
        expect(uploader).to have_received(:upload).with(a_string_matching(/responses.*\.csv/))
        follow_redirect!
        expect(response.body).to include(" responses")
        expect(Dir.glob(archive_glob)).to be_empty
      end

      it "keeps the file and shows an alert when the upload fails" do
        sign_in_as admin
        website = Website.create!(url: "https://example.com", user: admin)
        Response.create!(website: website, status_code: 200, response_time: 123, created_at: 2.days.ago)
        allow(uploader).to receive(:upload).and_return(false)

        post export_admin_archives_path

        expect(response).to redirect_to(admin_archives_path)
        follow_redirect!
        expect(response.body).to include("uploading to S3 failed")
        expect(response.body).to include("Download it now")
        expect(Dir.glob(archive_glob)).not_to be_empty
      end
    end
  end

  describe "POST /admin/archives/upload" do
    let(:archive_dir) { Rails.root.join("archive") }
    let(:file_name) { "responses_test.csv" }

    before do
      FileUtils.mkdir_p(archive_dir)
      File.write(archive_dir.join(file_name), "id,website_id")
    end

    after do
      FileUtils.rm_f(archive_dir.join(file_name))
    end

    it "uploads to S3 when credentials are configured" do
      sign_in_as admin
      uploader = instance_double(S3ArchiveUploader)
      allow(uploader).to receive(:upload).and_return(true)
      allow(ArchiveDayOldPingsJob).to receive(:build_s3_uploader).and_return(uploader)

      post upload_admin_archives_path, params: { filename: file_name }

      expect(response).to redirect_to(admin_archives_path)
      follow_redirect!
      expect(response.body).to include("Uploaded #{file_name}")
      expect(File.exist?(archive_dir.join(file_name))).to be(false)
    end

    it "requires AWS credentials" do
      sign_in_as admin
      allow(ArchiveDayOldPingsJob).to receive(:build_s3_uploader).and_return(nil)

      post upload_admin_archives_path, params: { filename: file_name }

      expect(response).to redirect_to(admin_archives_path)
      follow_redirect!
      expect(response.body).to include("Connect your AWS credentials")
      expect(File.exist?(archive_dir.join(file_name))).to be(true)
    end
  end
end
