class MasqueradesController < ApplicationController
  before_action :require_masquerade

  def destroy
    # Get the original admin user
    original_admin = User.find(session[:masquerade_admin_id])

    # Restore the original admin's ID
    session[:user_id] = session[:masquerade_admin_id]
    # Clear the masquerade flag
    session.delete(:masquerade_admin_id)

    # Restore the original admin's session with correct cookies
    start_new_session_for(original_admin, masquerade: false)

    redirect_to admin_users_path, notice: t(".stop_notice")
  end

  private

  def require_masquerade
    if session[:masquerade_admin_id].blank?
      redirect_to root_path, alert: t(".require_masquerade_alert")
    end
  end
end
