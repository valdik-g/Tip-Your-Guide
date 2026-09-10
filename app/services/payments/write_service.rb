module Payments
  class WriteService
    LOCK_TIMEOUT = 30
    CHECKOUT_SESSION_COMPLETE_STATUS = "complete"

    class LockIsNotAcquiredError < StandardError; end

    def self.with_lock(stripe_id:, &block)
      Payment.with_advisory_lock!(lock_name(stripe_id:), {timeout_seconds: 30}) do
        yield
      end
    end

    def self.lock_name(stripe_id:)
      "payment-#{stripe_id}"
    end

    attr_reader :stripe_checkout_session_id, :checkout_session, :user_id, :payment_info,
      :amount, :currency, :stripe_id, :stripe_payment_status, :payer_email,
      :payer_name

    def initialize(
      payment_info:, amount:, currency:, user_id:, stripe_id:,
      stripe_payment_status:, payer_email:, payer_name:
    )
      @payment_info = payment_info
      @amount = amount
      @currency = currency
      @user_id = user_id
      @stripe_id = stripe_id
      @stripe_payment_status = stripe_payment_status
      @payer_email = payer_email
      @payer_name = payer_name
    end

    def call
      raise LockIsNotAcquiredError unless Payment.advisory_lock_exists?(self.class.lock_name(stripe_id:))

      ActiveRecord::Base.transaction do
        payment = Payment.create_with(
          amount: amount,
          currency: currency,
          user_id: user_id,
          payment_info_id: payment_info.id,
          payer_email:,
          payer_name:
        ).find_or_create_by!(stripe_id:)

        upsert_payment_status(payment)

        payment
      end
    end

    private

    def upsert_payment_status(payment)
      last_status = payment.last_payment_status
      last_status.presence&.update!(last: false)

      Payment::Status.create!(
        payment: payment,
        kind: stripe_payment_status,
        last: true
      )
    end
  end
end
