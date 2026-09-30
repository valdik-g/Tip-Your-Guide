require "stripe"

# Sandbox setup: Stripe is configured from the environment so this app runs
# without encrypted credentials or a master key.
#
#   export STRIPE_SECRET_KEY=sk_test_...
#   export STRIPE_WEBHOOK_SIGNING_SECRET=whsec_...   # printed by `stripe listen`
#
# Use TEST keys only. Never commit real keys.
Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
StripeEvent.signing_secret = ENV["STRIPE_WEBHOOK_SIGNING_SECRET"]

# Handle Stripe webhook events.
# https://docs.stripe.com/api/events/object
#
# StripeEvent verifies the signature against the secret above before any
# subscriber runs. Requests with a missing or wrong signature never get here.
StripeEvent.configure do |events|
  events.subscribe "checkout.session.completed" do |event|
    session = event.data.object
    unless session.mode == 'subscription'
      Stripe::Checkout::Sessions::SyncFromProviderJob.perform_later(stripe_id: event.data.object.id)

      begin
        payload = {
          email: event.data.object.customer_details.email.to_s,
          name: event.data.object.customer_details.name.to_s,
          phone: event.data.object.customer_details.phone.to_s,
          amount: event.data.object.amount_total.to_f / 100,
          currency: event.data.object.currency.to_s,
          metadata: event.data.object.metadata.to_h
        }
        TelegramNotificationJob.perform_later(payload, type: :payment)
      rescue => e
        Rails.logger.error("TelegramNotificationJob error: #{e.message}")
      end
    end
  end

  events.subscribe "charge.refunded" do |event|
    charge = event.data.object
    if charge.payment_intent.present?
      Stripe::RefundJob.perform_later(stripe_id: charge.payment_intent)
    end
  end

  events.subscribe "customer.subscription.created" do |event|
    Subscriptions::SyncFromStripeJob.perform_later(
      stripe_subscription_id: event.data.object.id
    )
  end

  events.subscribe "customer.subscription.updated" do |event|
    Subscriptions::SyncFromStripeJob.perform_later(
      stripe_subscription_id: event.data.object.id
    )
  end

  events.subscribe "customer.subscription.deleted" do |event|
    Subscriptions::SyncFromStripeJob.perform_later(
      stripe_subscription_id: event.data.object.id
    )
  end

  events.all do |event|
    Rails.logger.info("Stripe event: #{event.type}")
  end
end
