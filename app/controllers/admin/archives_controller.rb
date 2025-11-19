module Admin
  class ArchivesController < BaseController
    ArchiveFile = Struct.new(:name, :size, :mtime, keyword_init: true)
    def index
      @archive_files = archive_files
      @s3_ready = ArchiveDayOldPingsJob.build_s3_uploader.present?
      @aws_setting = AwsArchiveSetting.current
    end

    def export
      result = ResponsesArchiveExporter.new.call

      if result.status == :no_data
        log_info("Admin::ArchivesController: export skipped because there were no responses older than one day")
        redirect_to admin_archives_path, alert: result.message
        return
      end

      if attempt_auto_upload(result)
        log_info("Admin::ArchivesController: archived #{result.archived_count} responses and uploaded #{result.file_name} to S3")
        redirect_to admin_archives_path
        return
      end

      log_info("Admin::ArchivesController: archived #{result.archived_count} responses locally as #{result.file_name}")
      flash[:notice] = export_flash_message(result)
      redirect_to admin_archives_path
    rescue StandardError => e
      log_error("Admin::ArchivesController: export failed - #{e.message}")
      redirect_to admin_archives_path, alert: "Unable to archive responses: #{e.message}"
    end

    def download
      file_path = archive_file_path(params[:filename])

      unless File.exist?(file_path)
        redirect_to admin_archives_path, alert: "Archive could not be found."
        return
      end

      safe_name = File.basename(file_path)
      send_file file_path, filename: safe_name, type: "text/csv"
    end

    def upload
      uploader = ArchiveDayOldPingsJob.build_s3_uploader
      unless uploader
        redirect_to admin_archives_path, alert: "Connect your AWS credentials before uploading to S3."
        return
      end

      file_path = archive_file_path(params[:filename])
      unless File.exist?(file_path)
        redirect_to admin_archives_path, alert: "Archive could not be found."
        return
      end

      if uploader.upload(file_path)
        if File.exist?(file_path)
          FileUtils.rm_f(file_path)
        else
          log_error("Admin::ArchivesController: local file missing after upload attempt: #{file_path}")
        end
        log_info("Admin::ArchivesController: uploaded #{File.basename(file_path)} to S3 via manual action")
        redirect_to admin_archives_path, notice: "Uploaded #{File.basename(file_path)} to S3 and removed the local copy."
      else
        log_error("Admin::ArchivesController: failed manual upload for #{File.basename(file_path)}")
        redirect_to admin_archives_path, alert: "Upload failed. Check your AWS credentials and try again."
      end
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

    def export_flash_message(result)
      view_context.safe_join([ result.message, download_link_for(result.file_name) ], " ")
    end

    def upload_failed_flash(result)
      message = "Saved #{result.archived_count} responses locally as #{result.file_name}, but uploading to S3 failed."
      view_context.safe_join([ message, download_link_for(result.file_name) ], " ")
    end

    def download_link_for(file_name)
      view_context.link_to(
        "Download it now",
        download_admin_archives_path(filename: file_name),
        class: "alert-link"
      )
    end

    def archive_file_path(filename)
      safe_name = File.basename(filename.to_s)
      archive_directory.join(safe_name)
    end

    def attempt_auto_upload(result)
      uploader = ArchiveDayOldPingsJob.build_s3_uploader
      return false unless uploader && result.file_path.present?

      unless File.exist?(result.file_path)
        flash[:alert] = "Archive could not be found for upload."
        log_error("Admin::ArchivesController: missing file for auto-upload: #{result.file_path}")
        return true
      end

      if uploader.upload(result.file_path)
        if File.exist?(result.file_path)
          FileUtils.rm_f(result.file_path)
        else
          log_error("Admin::ArchivesController: local file missing after auto-upload attempt: #{result.file_path}")
        end
        flash[:notice] = "Uploaded #{result.file_name} to S3 and removed the local copy."
        log_info("Admin::ArchivesController: automatic upload succeeded for #{result.file_name}")
      else
        flash[:alert] = upload_failed_flash(result)
        log_error("Admin::ArchivesController: automatic upload failed for #{result.file_name}")
      end

      true
    end

    def log_info(message)
      Rails.logger.info(message)
    end

    def log_error(message)
      Rails.logger.error(message)
    end
  end
end
