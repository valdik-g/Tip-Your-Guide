module Collections
  module Prices
    class SyncToProviderService
      attr_reader :collection_price

      def initialize(collection_price:)
        @collection_price = collection_price
      end

      def call
        stripe_price = find_stripe_price || create_stripe_price

        collection_price.update!(
          stripe_id: stripe_price.id
        )
      end

      private

      # @return [Stripe::Price, nil]
      def find_stripe_price
        stripe_price_service.find_stripe_price(price: collection_price.price, currency: collection_price.currency)
      end

      # @return [Stripe::Price]
      def create_stripe_price
        stripe_price_service.create_stripe_price(price: collection_price.price, currency: collection_price.currency)
      end

      def stripe_price_service
        @stripe_price_service ||= Stripe::ProductPriceService.new(stripe_product_id)
      end

      def stripe_product_id
        @stripe_product_id ||= payment_info.stripe_product_id
      end

      def payment_info
        collection_price.collection.user.collection_purchase_payment_info
      end
    end
  end
end
