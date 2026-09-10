require "administrate/field/base"

class GuideLinkField < Administrate::Field::Base
  def label
    I18n.t("helpers.custom.guide_link.label")
  end

  def url
    Rails.application.routes.url_helpers.guide_url(resource.to_param)
  end
end
