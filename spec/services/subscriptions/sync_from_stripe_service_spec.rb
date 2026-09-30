require "rails_helper"

RSpec.describe Subscriptions::SyncFromStripeService do
  let(:user) { create(:user, email: "test@example.com") }
  let(:stripe_period_end) { 1.month.from_now }
  let(:stripe_status) { "active" }
  let(:stripe_cancel_at_period_end) { false }
  let(:stripe_metadata) { {} }
  let(:stripe_customer) { {id: "cus_test", object: "customer", email: user.email} }
  
  let(:stripe_subscription) do
    Stripe::Util.convert_to_stripe_object({
      id: "sub_test",
      object: "subscription",
      customer: stripe_customer,
      status: stripe_status,
      cancel_at_period_end: stripe_cancel_at_period_end,
      metadata: stripe_metadata,
      items: {
        object: "list",
        data: [
          {id: "si_test", object: "subscription_item", current_period_end: stripe_period_end.to_i}
        ]
      }
    })
  end

  before do
    allow(Stripe::Subscription).to receive(:retrieve).and_return(stripe_subscription)
  end

  describe "#call" do
    context "when subscription exists" do
      let!(:subscription) { create(:subscription, user: user, stripe_subscription_id: "sub_test") }

      it "updates subscription attributes from Stripe" do
        result = described_class.new(stripe_subscription_id: "sub_test").call

        expect(result).to be_present
        expect(result.status).to eq("active")
        expect(result.cancel_at_period_end).to be false
        expect(result.stripe_customer_id).to eq("cus_test")
      end

      it "reads the period end from the subscription item" do
        result = described_class.new(stripe_subscription_id: "sub_test").call

        expect(result.current_period_end).to be_within(1.second).of(stripe_period_end)
      end

      it "takes the latest period end when the subscription has several items" do
        later_period_end = 2.months.from_now

        allow(Stripe::Subscription).to receive(:retrieve).and_return(
          Stripe::Util.convert_to_stripe_object({
            id: "sub_test",
            object: "subscription",
            customer: stripe_customer,
            status: "active",
            cancel_at_period_end: false,
            metadata: {},
            items: {
              object: "list",
              data: [
                {id: "si_1", object: "subscription_item", current_period_end: stripe_period_end.to_i},
                {id: "si_2", object: "subscription_item", current_period_end: later_period_end.to_i}
              ]
            }
          })
        )

        result = described_class.new(stripe_subscription_id: "sub_test").call

        expect(result.current_period_end).to be_within(1.second).of(later_period_end)
      end

      context "when the API still returns a top-level current_period_end" do
        let(:stripe_subscription) do
          Stripe::Util.convert_to_stripe_object({
            id: "sub_test",
            object: "subscription",
            customer: stripe_customer,
            status: "active",
            cancel_at_period_end: false,
            current_period_end: stripe_period_end.to_i,
            metadata: {},
            items: {object: "list", data: []}
          })
        end

        it "prefers it over the subscription item" do
          result = described_class.new(stripe_subscription_id: "sub_test").call

          expect(result.current_period_end).to be_within(1.second).of(stripe_period_end)
        end
      end

      context "when the API returns neither a top-level nor an item period end" do
        let(:stripe_subscription) do
          Stripe::Util.convert_to_stripe_object({
            id: "sub_test",
            object: "subscription",
            customer: stripe_customer,
            status: "active",
            cancel_at_period_end: false,
            metadata: {},
            items: {object: "list", data: [{id: "si_test", object: "subscription_item"}]}
          })
        end

        it "leaves the period end blank instead of raising" do
          result = described_class.new(stripe_subscription_id: "sub_test").call

          expect(result.current_period_end).to be_nil
        end
      end

      context "when the Stripe subscription is past_due" do
        let(:stripe_status) { "past_due" }

        it "maps past_due status correctly" do
          expect(described_class.new(stripe_subscription_id: "sub_test").call.status).to eq("past_due")
        end
      end

      context "when the Stripe subscription is canceled" do
        let(:stripe_status) { "canceled" }

        it "maps canceled status correctly" do
          expect(described_class.new(stripe_subscription_id: "sub_test").call.status).to eq("canceled")
        end

        context "when the paid period still has time left" do
          let(:stripe_ended_at) { 1.minute.ago }

          let(:stripe_subscription) do
            Stripe::Util.convert_to_stripe_object({
              id: "sub_test",
              object: "subscription",
              customer: stripe_customer,
              status: stripe_status,
              cancel_at_period_end: false,
              ended_at: stripe_ended_at.to_i,
              canceled_at: stripe_ended_at.to_i,
              metadata: stripe_metadata,
              items: {
                object: "list",
                data: [
                  {id: "si_test", object: "subscription_item", current_period_end: stripe_period_end.to_i}
                ]
              }
            })
          end

          it "ends the period when the subscription actually ended" do
            result = described_class.new(stripe_subscription_id: "sub_test").call

            expect(result.current_period_end).to be_within(1.second).of(stripe_ended_at)
          end

          it "does not report a period ending in the future" do
            result = described_class.new(stripe_subscription_id: "sub_test").call

            expect(result.current_period_end).to be_past
          end
        end

        context "when the API version has no ended_at" do
          let(:stripe_canceled_at) { 2.days.ago }

          let(:stripe_subscription) do
            Stripe::Util.convert_to_stripe_object({
              id: "sub_test",
              object: "subscription",
              customer: stripe_customer,
              status: stripe_status,
              cancel_at_period_end: false,
              canceled_at: stripe_canceled_at.to_i,
              metadata: stripe_metadata,
              items: {
                object: "list",
                data: [
                  {id: "si_test", object: "subscription_item", current_period_end: stripe_period_end.to_i}
                ]
              }
            })
          end

          it "falls back to canceled_at" do
            result = described_class.new(stripe_subscription_id: "sub_test").call

            expect(result.current_period_end).to be_within(1.second).of(stripe_canceled_at)
          end
        end

        context "when the subscription ended after the paid period" do
          let(:stripe_period_end) { 3.days.ago }
          let(:stripe_ended_at) { 1.day.ago }

          let(:stripe_subscription) do
            Stripe::Util.convert_to_stripe_object({
              id: "sub_test",
              object: "subscription",
              customer: stripe_customer,
              status: stripe_status,
              cancel_at_period_end: false,
              ended_at: stripe_ended_at.to_i,
              canceled_at: stripe_ended_at.to_i,
              metadata: stripe_metadata,
              items: {
                object: "list",
                data: [
                  {id: "si_test", object: "subscription_item", current_period_end: stripe_period_end.to_i}
                ]
              }
            })
          end

          it "keeps the earlier of the two dates" do
            result = described_class.new(stripe_subscription_id: "sub_test").call

            expect(result.current_period_end).to be_within(1.second).of(stripe_period_end)
          end
        end

        context "when the API reports no end at all" do
          it "leaves the period end alone instead of dropping it" do
            result = described_class.new(stripe_subscription_id: "sub_test").call

            expect(result.current_period_end).to be_within(1.second).of(stripe_period_end)
          end
        end
      end

      context "when the Stripe status is unknown" do
        let(:stripe_status) { "paused" }

        it "falls back to active" do
          expect(described_class.new(stripe_subscription_id: "sub_test").call.status).to eq("active")
        end
      end

      context "when cancel_at_period_end is set in Stripe" do
        let(:stripe_cancel_at_period_end) { true }

        it "syncs the flag" do
          expect(described_class.new(stripe_subscription_id: "sub_test").call.cancel_at_period_end).to be true
        end
      end

      context "when the customer is not expanded" do
        let(:stripe_customer) { "cus_test" }
        let(:stripe_metadata) { {user_id: user.id} }

        it "still uses the customer id" do
          user

          result = described_class.new(stripe_subscription_id: "sub_test").call

          expect(result.stripe_customer_id).to eq("cus_test")
        end
      end
    end

    context "when subscription does not exist" do
      it "creates a new subscription" do
        expect {
          described_class.new(stripe_subscription_id: "sub_test").call
        }.to change(Subscription, :count).by(1)
      end

      it "associates subscription with user by email" do
        result = described_class.new(stripe_subscription_id: "sub_test").call

        expect(result.user).to eq(user)
      end

      context "when the Stripe subscription carries the user id in metadata" do
        let(:other_user) { create(:user, email: "other@example.com") }
        let(:stripe_customer) { {id: "cus_test", object: "customer", email: other_user.email} }
        let(:stripe_metadata) { {user_id: other_user.id} }

        it "associates the subscription with that user" do
          result = described_class.new(stripe_subscription_id: "sub_test").call

          expect(result.user).to eq(other_user)
        end
      end

      context "when the Stripe email differs in case from the stored one" do
        let!(:user) { create(:user, email: "Test@Example.com") }
        let(:stripe_customer) { {id: "cus_test", object: "customer", email: "test@example.com "} }

        it "still finds the user" do
          expect(described_class.new(stripe_subscription_id: "sub_test").call.user).to eq(user)
        end
      end
    end

    context "when user not found" do
      let(:stripe_customer) { {id: "cus_test", object: "customer", email: "unknown@example.com"} }

      it "returns nil and does not create subscription" do
        expect {
          described_class.new(stripe_subscription_id: "sub_test").call
        }.not_to change(Subscription, :count)
      end

      it "returns nil" do
        service = described_class.new(stripe_subscription_id: "sub_test")
        expect(service.call).to be_nil
      end
    end

    context "when Stripe API fails" do
      before do
        allow(Stripe::Subscription).to receive(:retrieve).and_raise(
          Stripe::InvalidRequestError.new("Not found", "id")
        )
      end

      it "returns nil" do
        service = described_class.new(stripe_subscription_id: "sub_test")
        expect(service.call).to be_nil
      end

      it "does not create subscription" do
        expect {
          described_class.new(stripe_subscription_id: "sub_test").call
        }.not_to change(Subscription, :count)
      end
    end

    context "when the user renews a fully canceled subscription" do
      let!(:subscription) do
        create(:subscription, :canceled_expired, user: user, stripe_subscription_id: "sub_old")
      end

      let(:stripe_metadata) { {user_id: user.id} }

      it "reuses the existing row instead of adding a second one" do
        expect {
          described_class.new(stripe_subscription_id: "sub_test").call
        }.not_to change(Subscription, :count)

        expect(subscription.reload.stripe_subscription_id).to eq("sub_test")
      end

      it "reactivates the row" do
        result = described_class.new(stripe_subscription_id: "sub_test").call

        expect(result.status).to eq("active")
        expect(result.current_period_end).to be_within(1.second).of(stripe_period_end)
        expect(result.cancel_at_period_end).to be false
      end

      it "keeps the Stripe customer of the previous subscription" do
        result = described_class.new(stripe_subscription_id: "sub_test").call

        expect(result.stripe_customer_id).to eq("cus_test")
      end
    end

    context "when a late event arrives for the previous subscription after a renewal" do
      let!(:subscription) do
        create(:subscription, user: user, stripe_subscription_id: "sub_new", status: "active")
      end

      let(:stale_status) { "canceled" }
      let(:stale_period_end) { 2.days.ago }

      let(:stale_stripe_subscription) do
        Stripe::Util.convert_to_stripe_object({
          id: "sub_old",
          object: "subscription",
          customer: stripe_customer,
          status: stale_status,
          cancel_at_period_end: false,
          metadata: {user_id: user.id},
          items: {
            object: "list",
            data: [
              {id: "si_old", object: "subscription_item", current_period_end: stale_period_end.to_i}
            ]
          }
        })
      end

      it "ignores the event and leaves the renewed subscription alone" do
        allow(Stripe::Subscription).to receive(:retrieve).and_return(stale_stripe_subscription)

        expect(described_class.new(stripe_subscription_id: "sub_old").call.status).to eq("active")

        expect(subscription.reload.stripe_subscription_id).to eq("sub_new")
      end
    end
  end
end
