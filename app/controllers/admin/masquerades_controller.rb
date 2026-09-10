module Admin
  class MasqueradesController < Admin::ApplicationController
    before_action :require_admin

    def create
      user_to_masquerade = ::User.find(params[:id])

      unless user_to_masquerade.masqueradable?
        redirect_back_or_to(admin_users_path, alert: t(".guide_only_alert"))
        return
      end

      # Store the original admin ID
      session[:masquerade_admin_id] = current_user.id
      # Set the user ID to the masqueraded user
      session[:user_id] = user_to_masquerade.id

      # Start a new session with masquerade flag to preserve admin privileges
      start_new_session_for(user_to_masquerade, masquerade: true)

      redirect_to redirect_path_for(user_to_masquerade), notice: t(".start_notice", email: user_to_masquerade.email)
    end

    private

    def require_admin
      unless current_user&.has_role?(:admin)
        flash[:alert] = t("admin.authorization.denied")
        redirect_to root_path
      end
    end

    def redirect_path_for(user)
      authenticated_root_path
    end
  end
end
