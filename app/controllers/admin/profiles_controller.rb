module Admin
  class ProfilesController < Admin::ApplicationController
    def edit
      @user = current_user
      @subscription = current_user.subscription 

      render locals: {page: Administrate::Page::Form.new(UserProfileDashboard.new, @user), namespace: :admin}
    end

    def update
      @user = current_user

      if @user.update(user_params)
        flash[:success] = "Profile updated successfully"
        redirect_to edit_admin_profile_path
      else
        render :edit, status: :unprocessable_content,
          locals: {page: Administrate::Page::Form.new(UserProfileDashboard.new, @user), namespace: :admin}
      end
    end

    private

    def user_params
      params[:user].delete(:password) if params[:user][:password].blank?

      params.require(:user).permit(
        :full_name,
        :email,
        :city,
        :country,
        :bio,
        :password,
        :avatar
      )
    end
  end
end
