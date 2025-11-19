class ArchiveDayOldPingsJob < ApplicationJob
  queue_as :default

  def perform
    ResponsesArchiveExporter.new.call
  end

  def self.build_s3_uploader
    if (settings = AwsArchiveSetting.current)
      return settings.build_uploader
    end

    bucket = ENV["AWS_S3_ARCHIVE_BUCKET"]
    return if bucket.blank?

    S3ArchiveUploader.new(
      bucket: bucket,
      region: ENV.fetch("AWS_REGION"),
      access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID"),
      secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY"),
      session_token: ENV["AWS_SESSION_TOKEN"],
      key_prefix: ENV["AWS_S3_ARCHIVE_PREFIX"]
    )
  rescue KeyError, ArgumentError => e
    Rails.logger.error("Unable to configure S3 archive uploader: #{e.message}")
    nil
  end
end
