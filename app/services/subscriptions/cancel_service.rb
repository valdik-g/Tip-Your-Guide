module Subscriptions
  class CancelService
    attr_reader :subscription, :errors

    def initialize(subscription:)
      @subscription = subscription
      @errors = []
    end

    def call
      stripe_subscription = ::Stripe::Subscription.update(
        subscription.stripe_subscription_id,
        {cancel_at_period_end: true}
      )

      subscription.update!(
        cancel_at_period_end: true,
        current_period_end: PeriodEnd.call(stripe_subscription)
      )

      subscription
    rescue ::Stripe::StripeError => e
      @errors << e.message
      Rails.logger.error("[SUBSCRIPTION CANCEL] Stripe error: #{e.message}")
      nil
    rescue ActiveRecord::RecordInvalid => e
      @errors << e.record.errors.full_messages.join(", ")
      nil
    end
  end
end
