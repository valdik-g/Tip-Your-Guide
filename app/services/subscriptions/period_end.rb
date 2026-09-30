module Subscriptions
  module PeriodEnd
    def self.call(stripe_subscription)
      timestamp = top_level(stripe_subscription) || from_items(stripe_subscription)

      Time.zone.at(timestamp) if timestamp.present?
    end

    def self.top_level(stripe_subscription)
      stripe_subscription[:current_period_end]
    end
    private_class_method :top_level

    def self.from_items(stripe_subscription)
      items = stripe_subscription[:items]
      return if items.nil?

      Array(items[:data]).filter_map { |item| item[:current_period_end] }.max
    end
    private_class_method :from_items
  end
end
