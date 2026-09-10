require "administrate/field/base"

class MasqueradeLinkField < Administrate::Field::Base
  def label
    I18n.t("helpers.custom.masquerade_link.label", name: resource.full_name)
  end

  def url
    Rails.application.routes.url_helpers.admin_masquerade_path(resource.id)
  end

  def has_required_roles?
    resource.masqueradable?
    # && current_user.has_role?(:admin) && current_user.id != resource.id
  end

  def confirm_message
    I18n.t("helpers.custom.masquerade_link.confirm_message", email: resource.email)
  end
end
