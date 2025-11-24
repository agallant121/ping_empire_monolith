module ApplicationHelper
  def bootstrap_class_for(flash_type)
    case flash_type.to_sym
    when :notice
      "success"
    when :alert
      "danger"
    else
      "info"
    end
  end

  def language_options_for_select
    User::LANGUAGE_OPTIONS.map do |locale|
      [ t("languages.#{locale}"), locale ]
    end
  end

  def current_language_label
    t("languages.#{I18n.locale}")
  end
end
