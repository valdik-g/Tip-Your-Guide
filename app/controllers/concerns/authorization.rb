module Authorization
  extend ActiveSupport::Concern

  class NotAuthorizedError < StandardError; end

  included do
    rescue_from NotAuthorizedError, with: :handle_not_authorized
  end

  private

  def authorize_admin
    return if current_user&.is_admin? || admin_masquerading?

    raise NotAuthorizedError, t("errors.authorization.not_authorized")
  end

  def admin_masquerading?
    is_masquerading? && true_admin_user&.is_admin?
  end

  def handle_not_authorized
    redirect_to root_path, alert: t("errors.authorization.not_authorized")
  end
end
