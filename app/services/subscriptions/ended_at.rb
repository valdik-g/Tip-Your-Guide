module Subscriptions
  module EndedAt
    def self.call(stripe_subscription)
      timestamp = stripe_subscription[:ended_at] || stripe_subscription[:canceled_at]

      Time.zone.at(timestamp) if timestamp.present?
    end
  end
end
