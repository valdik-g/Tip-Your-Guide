require "rails_helper"

RSpec.describe Payments::WriteService, type: :service do
  let(:user) { create(:user) }
  let!(:payment_info) { create(:payment_info, user:) }
  let(:user_id) { user.id }
  let(:amount) { 100 }
  let(:currency) { "usd" }
  let(:stripe_id) { "stripe_123" }
  let(:stripe_payment_status) { "unpaid" }
  let(:payer_email) { "test@example.com" }
  let(:payer_name) { "John Doe" }

  subject do
    described_class.new(
      payment_info: payment_info,
      amount: amount,
      currency: currency,
      user_id: user_id,
      stripe_id: stripe_id,
      stripe_payment_status: stripe_payment_status,
      payer_email: payer_email,
      payer_name: payer_name
    )
  end

  describe ".with_lock" do
    it "executes the block within an advisory lock" do
      expect(Payment).to receive(:with_advisory_lock!).with("payment-#{stripe_id}", {timeout_seconds: 30}).and_yield
      described_class.with_lock(stripe_id: stripe_id) { "block executed" }
    end
  end

  describe "#call" do
    context "when lock is not acquired" do
      it "raises LockIsNotAcquiredError" do
        allow(Payment).to receive(:advisory_lock_exists?).and_return(false)
        expect { subject.call }.to raise_error(Payments::WriteService::LockIsNotAcquiredError)
      end
    end

    context "when lock is acquired" do
      before do
        allow(Payment).to receive(:advisory_lock_exists?).and_return(true)
      end

      it "creates a payment if it does not exist" do
        expect {
          subject.call
        }.to change(Payment, :count).by(1)
      end

      it "does not create a duplicate payment if it already exists" do
        create(:payment, stripe_id:, user:, payment_info:)
        expect {
          subject.call
        }.not_to change(Payment, :count)
      end

      it "creates a new payment status" do
        expect {
          subject.call
        }.to change(Payment::Status, :count).by(1)
      end

      it "marks the previous payment status as not last" do
        payment = create(:payment, stripe_id:, user:, payment_info:)
        create(:payment_status, payment:, last: true)

        subject.call

        expect(payment.payment_statuses.where(last: true).count).to eq(1)
        expect(payment.payment_statuses.where(last: false).count).to eq(1)
      end

      it "returns the payment object" do
        payment = subject.call
        expect(payment).to be_a(Payment)
        expect(payment.stripe_id).to eq(stripe_id)
      end
    end
  end
end
