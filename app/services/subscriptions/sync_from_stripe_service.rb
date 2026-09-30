module Subscriptions
  class SyncFromStripeService
    LOCK_TIMEOUT = 30

    STATUS_MAP = {
      "active" => "active",
      "past_due" => "past_due",
      "unpaid" => "past_due",
      "incomplete" => "incomplete",
      "incomplete_expired" => "canceled",
      "canceled" => "canceled"
    }.freeze
    UNKNOWN_STATUS = "active"

    def self.with_lock(stripe_subscription_id:, &block)
      Subscription.with_advisory_lock!(
        "subscription-#{stripe_subscription_id}", {timeout_seconds: LOCK_TIMEOUT}, &block
      )
    end

    attr_reader :stripe_subscription_id

    def initialize(stripe_subscription_id:)
      @stripe_subscription_id = stripe_subscription_id
    end

    def call
      stripe_subscription = fetch_subscription
      return if stripe_subscription.nil?

      user = find_user(stripe_subscription)
      if user.nil?
        Rails.logger.warn("[SUBSCRIPTION SYNC] No local user for #{stripe_subscription[:id]}")
        return
      end

      self.class.with_lock(stripe_subscription_id: stripe_subscription[:id]) do
        sync(user:, stripe_subscription:)
      end
    end

    private

    def sync(user:, stripe_subscription:)
      subscription = user.subscription || user.build_subscription

      if superseded?(subscription, stripe_subscription)
        Rails.logger.warn(
          "[SUBSCRIPTION SYNC] Ignoring #{stripe_subscription[:id]}: the row already follows " \
            "#{subscription.stripe_subscription_id} for user #{user.id}"
        )
        return subscription
      end

      status = map_status(stripe_subscription)

      subscription.assign_attributes(
        stripe_subscription_id: stripe_subscription[:id],
        stripe_customer_id: customer_id(stripe_subscription),
        status: status,
        current_period_end: period_end(stripe_subscription, status),
        cancel_at_period_end: stripe_subscription[:cancel_at_period_end] || false
      )

      subscription.save!
      subscription
    end

    def superseded?(subscription, stripe_subscription)
      subscription.stripe_subscription_id != stripe_subscription[:id] && !subscription.renewable?
    end

    def map_status(stripe_subscription)
      stripe_status = stripe_subscription[:status]
      return STATUS_MAP.fetch(stripe_status) if STATUS_MAP.key?(stripe_status)

      Rails.logger.warn("[SUBSCRIPTION SYNC] Unknown Stripe status #{stripe_status.inspect}")
      UNKNOWN_STATUS
    end

    def period_end(stripe_subscription, status)
      period_end = PeriodEnd.call(stripe_subscription)
      return period_end unless status == "canceled"

      ended_at = EndedAt.call(stripe_subscription)
      return period_end if ended_at.nil? || period_end.nil?

      [period_end, ended_at].min
    end

    def customer_id(stripe_subscription)
      customer = stripe_subscription[:customer]
      return if customer.nil?

      customer.is_a?(String) ? customer : customer[:id]
    end

    def find_user(stripe_subscription)
      metadata = stripe_subscription[:metadata] || {}
      user_id = metadata[:user_id] || metadata["user_id"]
      return User.find_by(id: user_id) if user_id.present?

      customer = stripe_subscription[:customer]
      return if customer.nil? || customer.is_a?(String)

      User.find_by("lower(email) = ?", customer[:email].to_s.strip.downcase)
    end

    def fetch_subscription
      ::Stripe::Subscription.retrieve({
        id: stripe_subscription_id,
        expand: ["customer"]
      })
    rescue ::Stripe::InvalidRequestError, ::Stripe::APIError => e
      Rails.logger.error("[SUBSCRIPTION SYNC] Stripe API error for #{stripe_subscription_id}: #{e.message}")
      nil
    end
  end
end
