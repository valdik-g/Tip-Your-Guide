require "rails_helper"

RSpec.describe Stripe::RefundHandlerService do
  let(:stripe_id) { "stripe_cs_test_123" }
  let(:service) { described_class.new(stripe_id) }

  describe "#initialize" do
    it "sets the stripe_id" do
      expect(service.stripe_id).to eq(stripe_id)
    end
  end

  describe "#call" do
    context "when payment exists" do
      let!(:user) { create(:user, email: "test#{rand(10000)}@example.com") }
      let!(:payment_info) { create(:payment_info, user:) }
      let!(:payment) { create(:payment, stripe_id:, user:, payment_info:) }

      context "when payment has no existing status" do
        it "creates a refunded status" do
          expect { service.call }.to change { payment.payment_statuses.count }.by(1)

          refunded_status = payment.payment_statuses.last
          expect(refunded_status.kind).to eq("refunded")
          expect(refunded_status.last).to be(true)
        end
      end

      context "when payment has an existing last status" do
        let!(:existing_status) { create(:payment_status, payment:, kind: "paid", last: true) }

        it "updates the existing status to not be last and creates a new refunded status" do
          expect { service.call }.to change { payment.payment_statuses.count }.by(1)

          existing_status.reload
          expect(existing_status.last).to be(false)

          refunded_status = payment.payment_statuses.last
          expect(refunded_status.kind).to eq("refunded")
          expect(refunded_status.last).to be(true)
        end

        it "performs the operation in a transaction" do
          allow_any_instance_of(ActiveRecord::Associations::CollectionProxy).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)

          expect { service.call }.to raise_error(ActiveRecord::RecordInvalid)

          existing_status.reload
          expect(existing_status.last).to be(true) # Should not be updated due to rollback
        end
      end

      context "when payment is already refunded" do
        let!(:refunded_status) { create(:payment_status, payment:, kind: "refunded", last: true) }

        it "does not create a new status" do
          expect { service.call }.not_to change { payment.payment_statuses.count }
        end

        it "returns early without processing" do
          expect(payment.payment_statuses).not_to receive(:create)
          service.call
        end
      end

      context "when payment has multiple statuses" do
        let!(:old_status) { create(:payment_status, payment:, kind: "unpaid", last: false) }
        let!(:current_status) { create(:payment_status, payment:, kind: "paid", last: true) }

        it "only updates the last status" do
          service.call

          old_status.reload
          current_status.reload

          expect(old_status.last).to be(false) # Should remain unchanged
          expect(current_status.last).to be(false) # Should be updated

          refunded_status = payment.payment_statuses.last
          expect(refunded_status.kind).to eq("refunded")
          expect(refunded_status.last).to be(true)
        end
      end
    end

    context "when payment does not exist" do
      it "returns early without creating any records" do
        expect { service.call }.not_to change { Payment::Status.count }
      end

      it "does not raise an error" do
        expect { service.call }.not_to raise_error
      end
    end

    context "when stripe_id is nil" do
      let(:stripe_id) { nil }

      it "returns early without creating any records" do
        expect { service.call }.not_to change { Payment::Status.count }
      end
    end

    context "when stripe_id is empty string" do
      let(:stripe_id) { "" }

      it "returns early without creating any records" do
        expect { service.call }.not_to change { Payment::Status.count }
      end
    end

    context "when database transaction fails" do
      let!(:user2) { create(:user, email: "test2#{rand(10000)}@example.com") }
      let!(:payment_info2) { create(:payment_info, user: user2) }
      let!(:payment) { create(:payment, stripe_id:, user: user2, payment_info: payment_info2) }
      let!(:existing_status) { create(:payment_status, payment:, kind: "paid", last: true) }

      before do
        allow_any_instance_of(ActiveRecord::Associations::CollectionProxy).to receive(:create!).and_raise(ActiveRecord::StatementInvalid)
      end

      it "rolls back all changes" do
        expect { service.call }.to raise_error(ActiveRecord::StatementInvalid)

        existing_status.reload
        expect(existing_status.last).to be(true)
      end
    end
  end
end
