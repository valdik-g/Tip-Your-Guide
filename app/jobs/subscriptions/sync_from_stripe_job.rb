module Subscriptions
  class SyncFromStripeJob < ApplicationJob
    queue_as :default

    def perform(stripe_subscription_id:)
      Subscriptions::SyncFromStripeService.new(
        stripe_subscription_id: stripe_subscription_id
      ).call
    end
  end
end
