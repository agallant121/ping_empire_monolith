module Admin
  class AwsSettingsController < BaseController
    def show
      @aws_setting = AwsArchiveSetting.current_or_build
    end

    def create
      @aws_setting = AwsArchiveSetting.new(aws_setting_params)
      if @aws_setting.save
        redirect_to admin_aws_settings_path, notice: "AWS credentials saved."
      else
        render :show, status: :unprocessable_entity
      end
    end

    def update
      @aws_setting = AwsArchiveSetting.current
      unless @aws_setting
        @aws_setting = AwsArchiveSetting.new(aws_setting_params)
        if @aws_setting.save
          redirect_to admin_aws_settings_path, notice: "AWS credentials saved."
        else
          render :show, status: :unprocessable_entity
        end
        return
      end

      if @aws_setting.update(aws_setting_params)
        redirect_to admin_aws_settings_path, notice: "AWS credentials updated."
      else
        render :show, status: :unprocessable_entity
      end
    end

    private

    def aws_setting_params
      params.require(:aws_archive_setting).permit(
        :access_key_id,
        :secret_access_key,
        :session_token,
        :region,
        :bucket,
        :key_prefix
      )
    end
  end
end
