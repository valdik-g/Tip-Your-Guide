require "rails_helper"

RSpec.describe Stripe::ProductPriceService do
  let(:stripe_product_id) { "prod_123" }
  let(:service) { described_class.new(stripe_product_id) }

  describe "#find_stripe_price" do
    let(:matching_price) do
      double("Stripe::Price",
        id: "price_123",
        unit_amount: 1000,
        currency: "eur")
    end

    let(:non_matching_price) do
      double("Stripe::Price",
        id: "price_456",
        unit_amount: 2000,
        currency: "usd")
    end

    let(:price_list) { [matching_price, non_matching_price] }

    before do
      allow(Stripe::Price).to receive(:list)
        .with(hash_including(product: stripe_product_id, type: "one_time"))
        .and_return(price_list)
    end

    context "when a matching price exists" do
      it "returns the matching price" do
        result = service.find_stripe_price(price: 1000, currency: "eur")
        expect(result).to eq(matching_price)
      end
    end

    context "when no matching price exists" do
      it "returns nil" do
        result = service.find_stripe_price(price: 3000, currency: "eur")
        expect(result).to be_nil
      end
    end

    context "when currency is not specified" do
      it "uses EUR as default currency" do
        result = service.find_stripe_price(price: 1000)
        expect(result).to eq(matching_price)
      end
    end
  end

  describe "#create_stripe_price" do
    let(:created_price) do
      double("Stripe::Price",
        id: "price_new",
        unit_amount: 1500,
        currency: "eur",
        product: stripe_product_id)
    end

    before do
      allow(Stripe::Price).to receive(:create).and_return(created_price)
    end

    it "creates a new price with the specified parameters" do
      expect(Stripe::Price).to receive(:create).with({
        product: stripe_product_id,
        unit_amount: 1500,
        currency: "eur"
      })

      result = service.create_stripe_price(price: 1500, currency: "eur")
      expect(result).to eq(created_price)
    end

    context "when currency is not specified" do
      it "uses EUR as default currency" do
        expect(Stripe::Price).to receive(:create).with({
          product: stripe_product_id,
          unit_amount: 1500,
          currency: "eur"
        })

        service.create_stripe_price(price: 1500)
      end
    end

    context "when Stripe API raises an error" do
      before do
        allow(Stripe::Price).to receive(:create).and_raise(Stripe::InvalidRequestError.new("Invalid params", "unit_amount"))
      end

      it "propagates the error" do
        expect {
          service.create_stripe_price(price: -100)
        }.to raise_error(Stripe::InvalidRequestError)
      end
    end
  end
end
