module Stripe
  module Checkout
    module Sessions
      class SyncFromProviderService
        CHECKOUT_SESSION_COMPLETE_STATUS = "complete".freeze

        attr_reader :stripe_id

        def initialize(stripe_id:)
          @stripe_id = stripe_id
        end

        def call
          return if session_not_completed?

          Payments::WriteService.with_lock(stripe_id: checkout_session.id) do
            Payments::WriteService.new(**attrs).call
          end
        end

        private

        def attrs
          {
            payment_info:,
            amount:,
            currency:,
            user_id: payment_info.user_id,
            stripe_id: checkout_session.id,
            payer_email:,
            payer_name:,
            stripe_payment_status: checkout_session.payment_status
          }
        end

        def session_not_completed?
          checkout_session.status != CHECKOUT_SESSION_COMPLETE_STATUS
        end

        # For now we always sell single product per checkout session
        def stripe_product_id
          @stripe_product_id ||=
            if checkout_session.payment_link.present?
              checkout_session.payment_link.line_items.first.price.product
            else
              checkout_session.line_items.first.price.product
            end
        end

        def payment_info
          PaymentInfo.find_by!(stripe_product_id:)
        end

        def amount
          checkout_session.amount_total
        end

        def currency
          checkout_session.currency
        end

        def payer_email
          checkout_session.customer_details.email
        end

        def payer_name
          checkout_session.customer_details.name
        end

        def checkout_session
          @checkout_session ||= ::Stripe::Checkout::Session.retrieve({
            id: stripe_id,
            expand: [
              "payment_intent",
              "payment_intent.payment_method",
              "line_items",
              "line_items.data.price.product"
            ]
          })
        end
      end
    end
  end
end
