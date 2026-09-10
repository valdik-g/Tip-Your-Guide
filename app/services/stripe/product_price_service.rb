module Stripe
  class ProductPriceService
    attr_reader :stripe_product_id

    def initialize(stripe_product_id)
      @stripe_product_id = stripe_product_id
    end

    # @param price [Integer]
    # @param currency [String]
    # @return [Stripe::Price, nil]
    def find_stripe_price(price:, currency: "eur")
      Stripe::Price.list({product: stripe_product_id, type: "one_time"}).find do |stripe_price|
        stripe_price.unit_amount == price && stripe_price.currency == currency
      end
    end

    # @param price [Integer]
    # @param currency [String]
    # @return [Stripe::Price]
    def create_stripe_price(price:, currency: "eur")
      Stripe::Price.create({
        product: stripe_product_id,
        unit_amount: price,
        currency: currency
      })
    end
  end
end
