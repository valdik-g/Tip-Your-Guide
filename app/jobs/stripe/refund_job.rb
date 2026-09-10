module Stripe
  class RefundJob < ApplicationJob
    queue_as :default

    def perform(stripe_id:)
      Stripe::RefundHandlerService.call(stripe_id)
    end
  end
end
