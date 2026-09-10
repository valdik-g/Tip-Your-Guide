require "rails_helper"

RSpec.describe TelegramNotificationJob, type: :job do
  let(:notifier) { instance_double(TelegramNotifier) }

  describe "#perform" do
    context "when type is :waitlist" do
      let(:waitlist) { create(:waitlist) }

      before do
        allow(TelegramNotifier).to receive(:new).with(waitlist).and_return(notifier)
      end

      it "sends notification successfully" do
        expect(notifier).to receive(:notify_new_waitlist).and_return(true)

        described_class.perform_now(waitlist.id, type: :waitlist)
      end

      context "when waitlist exists" do
        it "sends notification successfully" do
          expect(notifier).to receive(:notify_new_waitlist).and_return(true)

          described_class.perform_now(waitlist.id)
        end

        it "handles notification failure gracefully" do
          expect(notifier).to receive(:notify_new_waitlist).and_return(false)

          described_class.perform_now(waitlist.id)
        end
      end

      context "when waitlist does not exist" do
        it "logs error and does not raise" do
          expect(Rails.logger).to receive(:error).with(
            a_string_matching(/TelegramNotificationJob: Something happened with #{waitlist.id + 1}:/)
          )

          expect {
            described_class.perform_now(waitlist.id + 1)
          }.not_to raise_error
        end
      end
    end

    context "when type is :payment" do
      let(:payment_data) { double }

      before do
        allow(TelegramNotifier).to receive(:new).with(payment_data).and_return(notifier)
      end

      it "sends notification successfully" do
        expect(notifier).to receive(:notify_new_payment).and_return(true)

        described_class.perform_now(payment_data, type: :payment)
      end
    end
  end
end
