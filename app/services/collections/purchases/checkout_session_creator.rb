module Collections
  module Purchases
    class CheckoutSessionCreator
      class CollectionPriceMissingError < StandardError; end

      def initialize(collection)
        @collection = collection
      end

      def call
        collection_price = collection.collection_price
        raise CollectionPriceMissingError, "Collection price is missing" unless collection_price

        stripe_checkout_session = create_stripe_checkout_session(collection_price)

        capture_posthog_event(stripe_checkout_session)

        stripe_checkout_session
      end

      private

      attr_reader :collection

      def create_stripe_checkout_session(collection_price)
        Stripe::Checkout::Session.create({
          payment_method_types: ["card"],
          line_items: [
            {
              price: collection_price.stripe_id,
              quantity: 1
            },
            if tax_stripe_price
              {
                price: tax_stripe_price.respond_to?(:id) ? tax_stripe_price.id : tax_stripe_price,
                quantity: 1
              }
            else
              {}
            end
          ],
          mode: "payment",
          success_url:,
          cancel_url:,
          metadata: {
            collection_id: collection.id,
            token:
          }
        })
      end

      def tax_stripe_price
        return nil if tax_product_id.blank?

        @tax_stripe_price ||= begin
          stripe_price_service = Stripe::ProductPriceService.new(tax_product_id)
          collection_price = collection.collection_price
          tax_price = [collection_price.price * tax_percentage, 100].max.to_i

          stripe_price_service.find_stripe_price(price: tax_price, currency: collection_price.currency) ||
            stripe_price_service.create_stripe_price(price: tax_price, currency: collection_price.currency)
        rescue => e
          Rails.logger.error("Error creating tax stripe price: #{e.message}")
          nil
        end
      end

      # Sadly Stripe doesn't work correctly with encoded URLs parameters
      def success_url
        url = Rails.application.routes.url_helpers.success_collections_purchases_url(token:)
        "#{url}&session_id={CHECKOUT_SESSION_ID}"
      end

      def cancel_url
        Rails.application.routes.url_helpers.guide_url(user)
      end

      def user
        @user ||= collection.user
      end

      def token
        @token ||= Collections::Purchases::TokenCreator.new(collection).call
      end

      # Optional in the sandbox. Set both to add a tax line item to checkout:
      #   export STRIPE_TAX_PRODUCT_ID=prod_...
      #   export STRIPE_TAX_PERCENTAGE=21
      def tax_product_id
        ENV["STRIPE_TAX_PRODUCT_ID"]
      end

      def tax_percentage
        ENV.fetch("STRIPE_TAX_PERCENTAGE", 0).to_f / 100.0
      end

      def capture_posthog_event(stripe_checkout_session)
        PosthogClient.capture({
          distinct_id: stripe_checkout_session.metadata[:token],
          event: "collection_purchase",
          properties: {
            collection_id: collection.id
          }
        })
      end
    end
  end
end
