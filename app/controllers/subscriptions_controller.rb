class SubscriptionsController < ApplicationController
  before_action :set_subscription, only: [:destroy]

  def create
    if current_user.subscription&.accessible?
      redirect_to edit_admin_profile_url, alert: t('subscription.flash.already_subscribed')
      return
    end

    checkout_url = Subscriptions::CreateService.new(
      user: current_user,
      success_url: success_subscription_url,
      cancel_url: cancel_subscription_url
    ).call

    redirect_to checkout_url, allow_other_host: true, status: :see_other
  end

  def destroy
    service = Subscriptions::CancelService.new(subscription: @subscription)
    
    if service.call
      redirect_to root_path, notice: t('subscription.flash.canceled')
    else
      redirect_to root_path, alert: t('subscription.flash.error')
    end
  end

  def update_payment_method
    subscription = current_user.subscription

    unless subscription&.accessible?
      redirect_to root_path, alert: t('subscription.flash.no_active_subscription')
      return
    end

    session = ::Stripe::BillingPortal::Session.create(
      customer: subscription.stripe_customer_id,
      return_url: edit_admin_profile_url
    )

    redirect_to session.url, allow_other_host: true, status: :see_other
  end

  def success
    redirect_to edit_admin_profile_url, notice: t('subscription.flash.success')
  end

  def cancel
    redirect_to root_path, notice: t('subscription.flash.payment_canceled')
  end

  private

  def set_subscription
    @subscription = current_user.subscription
    
    unless @subscription&.active?
      redirect_to root_path, alert: t('subscription.flash.no_active_subscription')
    end
  end
end