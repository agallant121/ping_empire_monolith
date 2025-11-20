class AwsArchiveSetting < ApplicationRecord
  validates :access_key_id, :secret_access_key, :region, :bucket, presence: true

  def self.current
    order(created_at: :desc).first
  end

  def self.current_or_build
    current || new
  end

  def build_uploader
    S3ArchiveUploader.new(
      bucket: bucket,
      region: region,
      access_key_id: access_key_id,
      secret_access_key: secret_access_key,
      session_token: session_token,
      key_prefix: key_prefix
    )
  end
end
