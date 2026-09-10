class WaitlistsController < ApplicationController
  skip_before_action :require_authentication
  before_action :validate_cloudflare_turnstile, only: :create

  rescue_from RailsCloudflareTurnstile::Forbidden do
    redirect_to root_path, alert: t("waitlist.create.captcha_failed")
  end

  def create
    waitlist = Waitlist.find_or_initialize_by(email: params[:email])

    if !waitlist.new_record?
      redirect_to root_path, notice: t("waitlist.create.already_on_waitlist")
      return
    end

    waitlist.assign_attributes(waitlist_params)

    if waitlist.save
      session[:waitlist_email] = params[:email]
      redirect_to root_path, notice: t("waitlist.create.success")
    else
      flash.now[:alert] = waitlist.errors.full_messages.join(", ")
      render :new, status: :unprocessable_content
    end
  end

  private

  def waitlist_params
    params.permit(:email, :full_name, :country, :city, :reason, :extra_info)
  end
end
