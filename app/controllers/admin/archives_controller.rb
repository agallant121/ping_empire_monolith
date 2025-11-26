module Admin
  class ArchivesController < BaseController
    ArchiveFile = Struct.new(:name, :size, :mtime, keyword_init: true)

    def index
      @archive_files = archive_files
      @s3_ready = ArchiveDayOldPingsJob.build_s3_uploader.present?
      @aws_setting = AwsArchiveSetting.current
      @archive_directory = archive_directory
    end

    def export
      result = ResponsesArchiveExporter.new.call

      if result.status == :no_data
        log_info("Admin::ArchivesController: export skipped because there were no responses older than one day")
        redirect_to(
          admin_archives_path,
          alert: t("admin.archives.flash.no_data")
        )
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
      redirect_to(
        admin_archives_path,
        alert: t("admin.archives.flash.export_failed", error: e.message)
      )
    end

    def download
      file_path = archive_file_path(params[:filename])

      unless File.exist?(file_path)
        redirect_to admin_archives_path, alert: t("admin.archives.flash.download_missing")
        return
      end

      safe_name = File.basename(file_path)
      send_file file_path, filename: safe_name, type: "text/csv"
    end

    def upload
      uploader = ArchiveDayOldPingsJob.build_s3_uploader
      unless uploader
        redirect_to(
          admin_archives_path,
          alert: t("admin.archives.flash.aws_missing")
        )
        return
      end

      file_name = params[:filename].to_s
      if file_name.blank?
        redirect_to admin_archives_path, alert: t("admin.archives.flash.filename_missing")
        return
      end

      file_path = archive_file_path(file_name)
      unless File.exist?(file_path)
        redirect_to admin_archives_path, alert: t("admin.archives.flash.file_missing")
        return
      end

      if uploader.upload(file_path)
        path_str = archive_file_path(params[:filename].to_s).to_s

        if File.exist?(path_str)
          begin
            File.unlink(path_str)
            log_info("Admin::ArchivesController: removed local file: #{path_str}")
          rescue Errno::EACCES, Errno::ENOENT, Errno::EISDIR => e
            log_error("Admin::ArchivesController: error removing local file #{path_str} after upload: #{e.class}: #{e.message}")
            redirect_to admin_archives_path, notice: t("admin.archives.flash.upload_success_without_delete", filename: File.basename(path_str)) and return
          end
        else
          Rails.logger.warn("Admin::ArchivesController: archive file not found for deletion: #{path_str}")
        end

        log_info("Admin::ArchivesController: uploaded #{File.basename(file_path)} to S3 via manual action")
        redirect_to admin_archives_path, notice: t("admin.archives.flash.upload_success", filename: File.basename(file_path))
      else
        log_error("Admin::ArchivesController: failed manual upload for #{File.basename(file_path)}")
        error_detail = uploader.respond_to?(:last_error) ? uploader.last_error : nil
        redirect_to admin_archives_path, alert: upload_error_message(error_detail)
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

    def upload_failed_flash(result, error_detail = nil)
      message = t(
        "admin.archives.flash.upload_failed",
        count: result.archived_count,
        filename: result.file_name
      )
      message = "#{message} #{upload_error_message(error_detail)}"
      view_context.safe_join([ message, download_link_for(result.file_name) ], " ")
    end

    def download_link_for(file_name)
      view_context.link_to(
        t("admin.archives.flash.download_now"),
        download_admin_archives_path(filename: file_name),
        class: "alert-link"
      )
    end

    def archive_file_path(filename)
      safe_name = File.basename(filename.to_s)
      archive_directory.join(safe_name)
    end

    def upload_error_message(error_detail)
      base_message = t("admin.archives.flash.upload_failed_base")
      return base_message if error_detail.blank?

      sanitized_detail = error_detail.to_s.strip.sub(/\.*\z/, "")
      "#{base_message} #{t("admin.archives.flash.upload_failed_detail", detail: sanitized_detail)}"
    end

    def attempt_auto_upload(result)
      uploader = ArchiveDayOldPingsJob.build_s3_uploader
      return false unless uploader && result.file_path.present?

      unless File.exist?(result.file_path)
        flash[:alert] = t("admin.archives.flash.auto_upload_missing_file")
        log_error("Admin::ArchivesController: missing file for auto-upload: #{result.file_path}")
        return true
      end

      if uploader.upload(result.file_path)
        path_str = result.file_path.to_s

        if File.exist?(path_str)
          begin
            File.unlink(path_str)
            log_info("Admin::ArchivesController: removed local file after auto-upload: #{path_str}")
          rescue Errno::EACCES, Errno::ENOENT, Errno::EISDIR => e
            flash[:alert] = upload_failed_flash(result)
            log_error("Admin::ArchivesController: error removing file after auto-upload #{path_str}: #{e.class}: #{e.message}")
            return true
          end
        else
          Rails.logger.warn("Admin::ArchivesController: archive file not found for auto-upload deletion: #{path_str}")
        end

        flash[:notice] = t("admin.archives.flash.upload_success", filename: result.file_name)
        log_info("Admin::ArchivesController: automatic upload succeeded for #{result.file_name}")
      else
        error_detail = uploader.respond_to?(:last_error) ? uploader.last_error : nil
        flash[:alert] = upload_failed_flash(result, error_detail)
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
