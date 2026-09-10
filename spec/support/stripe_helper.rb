module StripeHelper
  # Stripe is configured from ENV in this app — see config/initializers/stripe.rb
  def stub_stripe_credentials
    stub_const("ENV", ENV.to_hash.merge(
      "STRIPE_SECRET_KEY" => "sk_test_123",
      "STRIPE_WEBHOOK_SIGNING_SECRET" => "whsec_test_123"
    ))

    Stripe.api_key = "sk_test_123"
  end

  def stub_stripe_price_search(find: true)
    price_service = instance_double(Stripe::ProductPriceService)
    allow(Stripe::ProductPriceService).to receive(:new).and_return(price_service)

    if find
      allow(price_service).to receive(:find_stripe_price).and_return(
        instance_double(Stripe::Price, id: "price_123", unit_amount: 1000, currency: "eur")
      )
    else
      allow(price_service).to receive(:find_stripe_price).and_return(nil)
    end

    allow(price_service).to receive(:create_stripe_price).and_return(
      instance_double(Stripe::Price, id: "price_456", unit_amount: 1000, currency: "eur")
    )
  end

  def stub_stripe_checkout_session_creation
    checkout_session = instance_double(
      Stripe::Checkout::Session,
      id: "cs_test_123",
      url: "https://checkout.stripe.com/pay/cs_test_123",
      metadata: {
        token: "token_123"
      },
      amount_total: 1000,
      currency: "eur"
    )
    allow(Stripe::Checkout::Session).to receive(:create).and_return(checkout_session)
    checkout_session
  end
end

RSpec.configure do |config|
  config.include StripeHelper, type: :feature
end
