# frozen_string_literal: true

require "csv"
require "fileutils"

class ResponsesArchiveExporter
  Result = Struct.new(:status, :file_path, :file_name, :message, :archived_count, keyword_init: true)

  def call
    responses = Response.more_than_one_day_old
    if responses.empty?
      log_info("ResponsesArchiveExporter: no responses older than one day to archive")
      return Result.new(
        status: :no_data,
        file_path: nil,
        file_name: nil,
        archived_count: 0,
        message: "No responses older than one day"
      )
    end

    archive_dir = Rails.root.join("archive")
    FileUtils.mkdir_p(archive_dir)

    file_path = archive_dir.join("responses#{Time.current.strftime("%Y-%m-%d_%H-%M-%S")}.csv")
    write_csv(file_path, responses)

    file_saved = File.exist?(file_path) && File.size?(file_path).to_i.positive?
    raise "CSV file not saved!" unless file_saved

    archived_count = responses.count
    responses.delete_all if file_saved

    log_info("ResponsesArchiveExporter: saved #{archived_count} responses to #{file_path}")

    Result.new(
      status: :saved_locally,
      file_path: file_path.to_s,
      file_name: File.basename(file_path),
      archived_count: archived_count,
      message: "Saved #{archived_count} responses to #{file_path}.",
    )
  end

  private

  def log_info(message)
    Rails.logger.info(message) if defined?(Rails)
  end

  def write_csv(file_path, responses)
    CSV.open(file_path, "w") do |csv|
      csv << %w[id website_id status_code response_time created_at]
      responses.find_each do |response|
        csv << [
          response.id,
          response.website_id,
          response.status_code,
          response.response_time,
          response.created_at
        ]
      end
    end
  end
end
