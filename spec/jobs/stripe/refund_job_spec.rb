require "rails_helper"

RSpec.describe Stripe::RefundJob, type: :job do
  include ActiveJob::TestHelper

  let(:stripe_id) { "stripe_cs_test_123" }

  describe "#perform" do
    before do
      allow(Stripe::RefundHandlerService).to receive(:call)
    end

    it "calls RefundHandlerService with the correct stripe_id" do
      expect(Stripe::RefundHandlerService).to receive(:call).with(stripe_id)
      described_class.perform_now(stripe_id: stripe_id)
    end

    context "when stripe_id is nil" do
      let(:stripe_id) { nil }

      it "still calls the service" do
        expect(Stripe::RefundHandlerService).to receive(:call).with(nil)
        described_class.perform_now(stripe_id: stripe_id)
      end
    end

    context "when RefundHandlerService raises an error" do
      before do
        allow(Stripe::RefundHandlerService).to receive(:call).and_raise(StandardError, "Service error")
      end

      it "propagates the error" do
        expect {
          described_class.perform_now(stripe_id: stripe_id)
        }.to raise_error(StandardError, "Service error")
      end
    end

    context "when RefundHandlerService raises ActiveRecord error" do
      before do
        allow(Stripe::RefundHandlerService).to receive(:call).and_raise(ActiveRecord::RecordNotFound)
      end

      it "propagates the ActiveRecord error" do
        expect {
          described_class.perform_now(stripe_id: stripe_id)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "job configuration" do
    it "is queued on the default queue" do
      expect(described_class.queue_name).to eq("default")
    end

    it "inherits from ApplicationJob" do
      expect(described_class.superclass).to eq(ApplicationJob)
    end
  end

  describe "job enqueueing" do
    it "enqueues the job with correct arguments" do
      expect {
        described_class.perform_later(stripe_id: stripe_id)
      }.to have_enqueued_job(described_class).with(stripe_id: stripe_id)
    end

    it "enqueues the job on the default queue" do
      expect {
        described_class.perform_later(stripe_id: stripe_id)
      }.to have_enqueued_job(described_class).on_queue("default")
    end
  end

  describe "integration test" do
    let!(:user) { create(:user, email: "integration#{rand(10000)}@example.com") }
    let!(:payment_info) { create(:payment_info, user: user) }
    let!(:payment) { create(:payment, stripe_id: stripe_id, user: user, payment_info: payment_info) }
    let!(:existing_status) { create(:payment_status, payment: payment, kind: "paid", last: true) }

    it "actually processes the refund through the service" do
      perform_enqueued_jobs do
        described_class.perform_later(stripe_id: stripe_id)
      end

      existing_status.reload
      expect(existing_status.last).to be(false)

      refunded_status = payment.payment_statuses.last
      expect(refunded_status.kind).to eq("refunded")
      expect(refunded_status.last).to be(true)
    end

    context "when payment doesn't exist" do
      let(:stripe_id) { "nonexistent_stripe_id" }

      it "completes without error" do
        expect {
          perform_enqueued_jobs do
            described_class.perform_later(stripe_id: stripe_id)
          end
        }.not_to raise_error
      end
    end
  end
end
