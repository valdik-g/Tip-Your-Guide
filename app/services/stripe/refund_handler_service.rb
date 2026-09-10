module Stripe
  class RefundHandlerService
    attr_reader :stripe_id

    def initialize(stripe_id)
      @stripe_id = stripe_id
    end

    def self.call(stripe_id)
      new(stripe_id).call
    end

    def call
      payment = Payment.find_by(stripe_id:)
      return unless payment

      last_status = payment.last_payment_status
      return if last_status&.kind == "refunded"

      ActiveRecord::Base.transaction do
        last_status.presence&.update!(last: false)

        payment.payment_statuses.create!(
          kind: :refunded,
          last: true
        )
      end
    end
  end
end
