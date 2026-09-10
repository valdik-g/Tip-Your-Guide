require "rails_helper"

RSpec.describe Collections::Prices::SyncToProviderService do
  let(:collection) { create(:collection) }
  let(:payment_info) { create(:payment_info, :collection_purchase, user: collection.user) }
  let(:collection_price) { create(:collection_price, collection:, payment_info:) }
  let(:service) { described_class.new(collection_price:) }

  describe "#call" do
    let(:stripe_price) { double("Stripe::Price", id: "price_123") }
    let(:price_service) { instance_double(Stripe::ProductPriceService) }

    before do
      allow(Stripe::ProductPriceService).to receive(:new).and_return(price_service)
    end

    context "when a matching Stripe price exists" do
      before do
        allow(price_service).to receive(:find_stripe_price)
          .with(price: collection_price.price, currency: collection_price.currency)
          .and_return(stripe_price)
      end

      it "updates the collection_price with the Stripe price ID" do
        service.call
        expect(collection_price.reload.stripe_id).to eq("price_123")
      end
    end

    context "when no matching Stripe price exists" do
      before do
        allow(price_service).to receive(:find_stripe_price)
          .with(price: collection_price.price, currency: collection_price.currency)
          .and_return(nil)
        allow(price_service).to receive(:create_stripe_price)
          .with(price: collection_price.price, currency: collection_price.currency)
          .and_return(stripe_price)
      end

      it "creates a new Stripe price and updates the collection_price with the Stripe price ID" do
        expect(price_service).to receive(:create_stripe_price)
          .with(price: collection_price.price, currency: collection_price.currency)

        service.call
        expect(collection_price.reload.stripe_id).to eq("price_123")
      end
    end
  end
end
