require "rails_helper"

RSpec.describe Stripe::Checkout::Sessions::SyncFromProviderService, type: :service do
  describe "#call" do
    let(:checkout_session_id) { "cs_test_123" }

    let(:checkout_session) do
      Stripe::Checkout::Session.construct_from({
        id: checkout_session_id,
        status: checkout_session_status,
        payment_status: "paid",
        amount_total: 1000,
        currency: "usd",
        customer_details: Stripe::StripeObject.construct_from({
          email: "test@example.com",
          name: "Test User"
        }),
        payment_link: nil,
        line_items: [
          Stripe::StripeObject.construct_from({
            price: Stripe::StripeObject.construct_from({
              product: "prod_123"
            })
          })
        ]
      })
    end

    let(:payment_info) { instance_double(PaymentInfo, user_id: 1, stripe_product_id: "prod_123") }

    subject { described_class.new(stripe_id: checkout_session_id) }

    before do
      allow(::Stripe::Checkout::Session).to receive(:retrieve).with({
        id: checkout_session_id,
        expand: [
          "payment_intent",
          "payment_intent.payment_method",
          "line_items",
          "line_items.data.price.product"
        ]
      }).and_return(checkout_session)

      allow(PaymentInfo).to receive(:find_by!).with(stripe_product_id: "prod_123").and_return(payment_info)
      allow(Payments::WriteService).to receive(:with_lock).and_yield
      allow_any_instance_of(Payments::WriteService).to receive(:call)
    end

    context "when the session is not completed" do
      let(:checkout_session_status) { "open" }

      it "does not call Payments::WriteService" do
        subject.call
        expect(Payments::WriteService).not_to have_received(:with_lock)
      end
    end

    context "when the session is completed" do
      let(:checkout_session_status) { "complete" }

      it "calls Payments::WriteService with the correct parameters" do
        expect(Payments::WriteService).to receive(:with_lock).with(stripe_id: checkout_session_id).and_call_original
        expect(Payments::WriteService).to receive(:new).with(
          payment_info: payment_info,
          amount: 1000,
          currency: "usd",
          user_id: 1,
          stripe_id: checkout_session_id,
          payer_email: "test@example.com",
          payer_name: "Test User",
          stripe_payment_status: "paid"
        ).and_call_original

        subject.call
      end
    end

    context "when PaymentInfo is not found" do
      let(:checkout_session_status) { "complete" }

      before do
        allow(PaymentInfo).to receive(:find_by!).and_raise(ActiveRecord::RecordNotFound)
      end

      it "raises an error" do
        expect { subject.call }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
