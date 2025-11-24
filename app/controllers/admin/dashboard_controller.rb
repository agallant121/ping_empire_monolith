module Admin
  class DashboardController < BaseController
    ArchiveFile = Struct.new(:name, :size, :mtime, keyword_init: true)

    def show
      @total_websites = Website.count
      @incident_websites = Website.with_failures_since(Time.current.beginning_of_day).count
      @failed_responses_today = failed_responses_today
      @archive_files = archive_files.first(3)
      @s3_ready = ArchiveDayOldPingsJob.build_s3_uploader.present?
      @aws_setting = AwsArchiveSetting.current
    end

    private

    def archive_files
      Dir.glob(archive_directory.join("responses*.csv")).sort.reverse.map do |file|
        ArchiveFile.new(
          name: File.basename(file),
          size: File.size(file),
          mtime: File.mtime(file)
        )
      end
    end

    def archive_directory
      Rails.root.join("archive")
    end

    def failed_responses_today
      Response
        .where("status_code >= :min_status OR error IS NOT NULL", min_status: 400)
        .where("created_at >= ?", Time.current.beginning_of_day)
        .count
    end
  end
end
