require "csv"

class ArchiveDayOldPingsJob < ApplicationJob
  queue_as :default

  def perform
    responses = Response.more_than_one_day_old
    return if responses.empty?

    archive_dir = Rails.root.join("archive")
    FileUtils.mkdir_p(archive_dir) # ✅ Ensure the folder exists

    file_path = archive_dir.join("responses#{Time.current.strftime("%Y-%m-%d_%H-%M-%S")}.csv")

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

    file_saved = File.exist?(file_path) && File.size?(file_path) > 0
    raise "CSV file not saved!" unless file_saved

    responses.delete_all if file_saved
  end
end
