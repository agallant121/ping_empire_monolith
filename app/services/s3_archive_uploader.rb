# frozen_string_literal: true

require "digest"
require "net/http"
require "openssl"

class S3ArchiveUploader
  def initialize(bucket:, region:, access_key_id:, secret_access_key:, session_token: nil, key_prefix: nil)
    raise ArgumentError, "bucket is required" if bucket.blank?
    raise ArgumentError, "region is required" if region.blank?
    raise ArgumentError, "access key id is required" if access_key_id.blank?
    raise ArgumentError, "secret access key is required" if secret_access_key.blank?

    @bucket = bucket
    @region = region
    @access_key_id = access_key_id
    @secret_access_key = secret_access_key
    @session_token = session_token
    @key_prefix = normalize_prefix(key_prefix)
  end

  def upload(file_path)
    raise ArgumentError, "file does not exist" unless File.exist?(file_path)

    begin
      body = File.binread(file_path)
      digest = Digest::SHA256.hexdigest(body)
      timestamp = Time.now.utc
      amz_date = timestamp.strftime("%Y%m%dT%H%M%SZ")
      date_stamp = timestamp.strftime("%Y%m%d")
      key = object_key_for(file_path)

      canonical_request = canonical_request_for(key, amz_date, digest)
      string_to_sign = string_to_sign_for(canonical_request, amz_date, date_stamp)
      signature = signature_for(string_to_sign, date_stamp)

      request = build_request(key, body, amz_date, digest, signature, date_stamp)
      response = http_client(request.uri).request(request)

      if response.is_a?(Net::HTTPSuccess)
        log_info("S3ArchiveUploader: uploaded #{file_path} to s3://#{bucket}/#{key}")
        true
      else
        log_error("S3 upload failed for #{file_path} with status #{response.code} - #{response.body}")
        false
      end
    rescue StandardError => e
      log_error("S3 upload error for #{file_path}: #{e.message}")
      false
    end
  end

  private

  attr_reader :bucket, :region, :access_key_id, :secret_access_key, :session_token, :key_prefix

  def log_error(message)
    Rails.logger.error(message) if defined?(Rails)
  end

  def log_info(message)
    Rails.logger.info(message) if defined?(Rails)
  end

  def normalize_prefix(prefix)
    return if prefix.blank?

    trimmed = prefix.gsub(%r{^/+|/+$}, "")
    trimmed.presence
  end

  def host
    "#{bucket}.s3.#{region}.amazonaws.com"
  end

  def object_key_for(file_path)
    parts = [ key_prefix, File.basename(file_path) ].compact
    parts.join("/")
  end

  def canonical_request_for(key, amz_date, digest)
    headers = canonical_headers(amz_date, digest)
    signed_headers = signed_headers_list
    [
      "PUT",
      "/#{key}",
      "",
      headers,
      signed_headers,
      digest
    ].join("\n")
  end

  def canonical_headers(amz_date, digest)
    headers = [
      "host:#{host}",
      "x-amz-content-sha256:#{digest}",
      "x-amz-date:#{amz_date}"
    ]
    headers << "x-amz-security-token:#{session_token}" if session_token.present?
    headers.join("\n") + "\n"
  end

  def signed_headers_list
    headers = %w[host x-amz-content-sha256 x-amz-date]
    headers << "x-amz-security-token" if session_token.present?
    headers.join(";")
  end

  def string_to_sign_for(canonical_request, amz_date, date_stamp)
    credential_scope = credential_scope_for(date_stamp)
    [
      "AWS4-HMAC-SHA256",
      amz_date,
      credential_scope,
      Digest::SHA256.hexdigest(canonical_request)
    ].join("\n")
  end

  def credential_scope_for(date_stamp)
    "#{date_stamp}/#{region}/s3/aws4_request"
  end

  def signature_for(string_to_sign, date_stamp)
    signing_key = hmac(hmac(hmac(hmac("AWS4#{secret_access_key}", date_stamp), region), "s3"), "aws4_request")
    OpenSSL::HMAC.hexdigest("sha256", signing_key, string_to_sign)
  end

  def build_request(key, body, amz_date, digest, signature, date_stamp)
    uri = URI::HTTPS.build(host: host, path: "/#{key}")
    request = Net::HTTP::Put.new(uri)
    request.body = body
    request["x-amz-date"] = amz_date
    request["x-amz-content-sha256"] = digest
    request["Authorization"] = authorization_header(signature, date_stamp)
    request["x-amz-security-token"] = session_token if session_token.present?
    request
  end

  def authorization_header(signature, date_stamp)
    "AWS4-HMAC-SHA256 Credential=#{access_key_id}/#{credential_scope_for(date_stamp)}, SignedHeaders=#{signed_headers_list}, Signature=#{signature}"
  end

  def http_client(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 60
    http
  end

  def hmac(key, data)
    OpenSSL::HMAC.digest("sha256", key, data)
  end
end
