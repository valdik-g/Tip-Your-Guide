require "rails_helper"

RSpec.describe Collections::Purchases::CheckoutSessionCreator do
  let(:collection) { create(:collection) }
  let(:service) { described_class.new(collection) }
  let!(:payment_info) { create(:payment_info, :collection_purchase, user: collection.user) }

  let!(:collection_price) { create(:collection_price, collection:, payment_info:) }

  describe "#call" do
    let(:stripe_price) { double("Stripe::Price", id: "price_123") }
    let(:stripe_session) { double("Stripe::Checkout::Session", url: "https://stripe.com/checkout", metadata: {token: "jwt_token_123"}) }
    let(:token) { "jwt_token_123" }

    before do
      allow(Stripe::Price).to receive(:create).and_return(stripe_price)
      allow(Stripe::Checkout::Session).to receive(:create).and_return(stripe_session)
      allow(Collections::Purchases::TokenCreator).to receive_message_chain(:new, :call).and_return(token)
      allow(Rails.application.routes.url_helpers).to receive(:success_collections_purchases_url).and_return("http://example.com/success")
      allow(Rails.application.routes.url_helpers).to receive(:guide_url).and_return("http://example.com/guide")
    end

    it "creates a Stripe checkout session with correct attributes" do
      expected_args = {
        payment_method_types: ["card"],
        mode: "payment",
        success_url: "http://example.com/success&session_id={CHECKOUT_SESSION_ID}",
        cancel_url: "http://example.com/guide",
        metadata: {
          collection_id: collection.id,
          token: token
        },
        line_items: array_including(hash_including(price: collection_price.stripe_id, quantity: 1))
      }

      expect(Stripe::Checkout::Session).to receive(:create).with(hash_including(expected_args))
      service.call
    end

    it "captures a posthog event" do
      expected_args = {
        distinct_id: token,
        event: "collection_purchase",
        properties: {collection_id: collection.id}
      }

      expect(PosthogClient).to receive(:capture).with(hash_including(expected_args))
      service.call
    end

    it "returns the Stripe checkout session" do
      expect(service.call).to eq(stripe_session)
    end

    context "when collection price is not present then calls fail" do
      let(:collection_price) { nil }

      it "raises the CollectionPriceMissingError error" do
        expect { service.call }.to raise_error(described_class::CollectionPriceMissingError, "Collection price is missing")
      end
    end

    context "when tax price is present" do
      let(:tax_price_id) { "tax_price_1" }

      before do
        allow(service).to receive(:tax_stripe_price).and_return(tax_price_id)
      end

      it "includes the tax line item in the checkout session" do
        expect(Stripe::Checkout::Session).to receive(:create).with(
          hash_including(
            line_items: array_including(
              hash_including(price: collection_price.stripe_id, quantity: 1),
              hash_including(price: tax_price_id, quantity: 1)
            )
          )
        )

        service.call
      end
    end
  end
end
