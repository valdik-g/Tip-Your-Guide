# frozen_string_literal: true

module Payments
  class RowComponent < ApplicationComponent
    with_collection_parameter :payment

    attr_reader :payment

    def initialize(payment:)
      @payment = payment
    end

    def amount
      helpers.amount_with_currency(amount: payment.amount, currency: payment.currency)
    end

    def payer_name
      return "Anonymous" if payment.payer_name.blank?
      first_name, last_name = payment.payer_name.split(" ", 2)
      "#{first_name} #{last_name&.first}."
    end

    def status_color
      case payment.last_payment_status.kind&.to_s&.downcase
      when "paid"
        "bg-green-100 text-green-800"
      when "no_payment_required", "unpaid"
        "bg-yellow-100 text-yellow-800"
      when "failed", "declined", "error", "refunded"
        "bg-red-100 text-red-800"
      else
        "bg-gray-100 text-gray-800"
      end
    end
  end
end
