require "rails_helper"

RSpec.describe WaitlistStatusProcessorJob, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.new.perform(waitlist_id) }

    let(:waitlist_id) { waitlist.id }
    let(:waitlist) { create(:waitlist) }

    context "when waitlist exists" do
      it "processes the waitlist status" do
        processor = instance_double(WaitlistStatusProcessor)
        allow(WaitlistStatusProcessor).to receive(:new).with(waitlist).and_return(processor)
        expect(processor).to receive(:process)

        perform
      end
    end

    context "when waitlist does not exist" do
      let(:waitlist_id) { 999_999 }

      it "logs an error" do
        expect(Rails.logger).to receive(:error).with(/Failed to find waitlist #{waitlist_id}/)
        perform
      end

      it "does not raise an error" do
        expect { perform }.not_to raise_error
      end
    end
  end
end
