require "rails_helper"

RSpec.describe Subscriptions::CreateService do
  let(:user) { create(:user) }
  let(:success_url) { "http://localhost:3000/subscription/success" }
  let(:cancel_url) { "http://localhost:3000/subscription/cancel" }
  let(:price_id) { "price_test" }
  let(:checkout_session) { double(url: "https://checkout.stripe.com/test-session") }

  before do
    stub_const("ENV", ENV.to_hash.merge("SUBSCRIPTION_STRIPE_PRICE_ID" => price_id))
    allow(Stripe::Checkout::Session).to receive(:create).and_return(checkout_session)
  end

  describe "#call" do
    it "creates a Stripe checkout session" do
      service = described_class.new(
        user: user,
        success_url: success_url,
        cancel_url: cancel_url
      )

      result = service.call

      expect(Stripe::Checkout::Session).to have_received(:create).with(
        mode: "subscription",
        customer_email: user.email,
        line_items: [{
          price: price_id,
          quantity: 1
        }],
        subscription_data: {metadata: {user_id: user.id}},
        success_url: success_url,
        cancel_url: cancel_url
      )

      expect(result).to eq("https://checkout.stripe.com/test-session")
    end

    context "when the user already has a Stripe customer" do
      let!(:subscription) do
        create(:subscription, user: user, stripe_customer_id: "cus_existing")
      end

      it "reuses it instead of the email" do
        described_class.new(
          user: user,
          success_url: success_url,
          cancel_url: cancel_url
        ).call

        expect(Stripe::Checkout::Session).to have_received(:create).with(
          hash_including(customer: "cus_existing")
        )
      end
    end

    it "raises error when Stripe API fails" do
      allow(Stripe::Checkout::Session).to receive(:create).and_raise(
        Stripe::StripeError.new("API error")
      )

      service = described_class.new(
        user: user,
        success_url: success_url,
        cancel_url: cancel_url
      )

      expect { service.call }.to raise_error(Stripe::StripeError)
    end
  end
end
