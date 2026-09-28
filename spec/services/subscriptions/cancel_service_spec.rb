require "rails_helper"

RSpec.describe Subscriptions::CancelService do
  let(:user) { create(:user) }
  let(:subscription) { create(:subscription, :active, user: user) }
  let(:stripe_period_end) { 1.month.from_now }

  let(:stripe_subscription) do
    Stripe::Util.convert_to_stripe_object({
      id: subscription.stripe_subscription_id,
      object: "subscription",
      status: "active",
      cancel_at_period_end: true,
      items: {
        object: "list",
        data: [{id: "si_test", object: "subscription_item", current_period_end: stripe_period_end.to_i}]
      }
    })
  end

  describe "#call" do
    context "when Stripe API succeeds" do
      before do
        allow(Stripe::Subscription).to receive(:update).and_return(stripe_subscription)
      end

      it "updates subscription with cancel_at_period_end flag" do
        service = described_class.new(subscription: subscription)
        result = service.call

        expect(result.cancel_at_period_end).to be true
        expect(result.status).to eq("active")
        expect(Stripe::Subscription).to have_received(:update).with(
          subscription.stripe_subscription_id,
          {cancel_at_period_end: true}
        )
      end

      it "reads the period end from the subscription item" do
        service = described_class.new(subscription: subscription)
        result = service.call

        expect(result.current_period_end).to be_within(1.second).of(stripe_period_end)
      end

      it "returns the subscription" do
        service = described_class.new(subscription: subscription)
        expect(service.call).to eq(subscription)
      end
    end

    context "when Stripe API fails" do
      before do
        allow(Stripe::Subscription).to receive(:update).and_raise(
          Stripe::StripeError.new("Card declined")
        )
      end

      it "returns nil and adds error" do
        service = described_class.new(subscription: subscription)
        result = service.call

        expect(result).to be_nil
        expect(service.errors).to include("Card declined")
      end

      it "does not update the subscription" do
        service = described_class.new(subscription: subscription)
        service.call

        expect(subscription.reload.cancel_at_period_end).to be false
      end
    end
  end
end
