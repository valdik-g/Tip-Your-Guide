module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?, :current_user, :is_masquerading?, :true_admin_user
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private

  def authenticated?
    resume_session
  end

  def require_authentication
    current_user || resume_session || request_authentication
  end

  def resume_session
    return true if is_masquerading?

    Current.session ||= find_session_by_cookie
  end

  def current_user
    resume_session unless Current.session
    user_id = session[:user_id] || Current.session&.user_id
    return nil unless user_id
    @current_user = nil if @current_user && @current_user.id != user_id

    @current_user ||= User.find_by(id: user_id)
  end

  def is_masquerading?
    session[:masquerade_admin_id].present?
  end

  def true_admin_user
    return nil unless is_masquerading?

    @true_admin_user ||= User.find_by(id: session[:masquerade_admin_id])
  end

  def find_session_by_cookie
    Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
  end

  def request_authentication
    session[:return_to_after_authenticating] = request.url
    redirect_to new_session_path
  end

  def after_authentication_url
    session.delete(:return_to_after_authenticating) || root_url
  end

  def start_new_session_for(user, masquerade: true)
    unless masquerade
      session.delete(:masquerade_admin_id)
      session.delete(:user_id)
    end

    user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
      Current.session = session
      cookies.signed.permanent[:session_id] = {value: session.id, httponly: true, same_site: :lax}
    end
  end

  def terminate_session
    Current.session&.destroy

    cookies.delete(:session_id)
    session.delete(:masquerade_admin_id)
    session.delete(:user_id)

    Current.session = nil
    @current_user = nil
    @true_admin_user = nil
  end
end
