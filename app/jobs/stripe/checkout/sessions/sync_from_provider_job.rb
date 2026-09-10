module Stripe
  module Checkout
    module Sessions
      class SyncFromProviderJob < ApplicationJob
        queue_as :default

        def perform(stripe_id:)
          Stripe::Checkout::Sessions::SyncFromProviderService.new(stripe_id:).call
        end
      end
    end
  end
end
