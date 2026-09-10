require "rails_helper"

RSpec.describe Waitlist, type: :model do
  describe "callbacks" do
    describe "after_update_commit" do
      context "when status changes" do
        it "enqueues status processor job" do
          waitlist = create(:waitlist)
          expect {
            waitlist.update!(status: :rejected)
          }.to have_enqueued_job(WaitlistStatusProcessorJob)
            .with(waitlist.id)
            .on_queue(:default)
        end
      end

      context "when other attributes change" do
        it "does not enqueue status processor job" do
          waitlist = create(:waitlist)
          expect {
            waitlist.update!(full_name: "New Name")
          }.not_to have_enqueued_job(WaitlistStatusProcessorJob)
        end
      end

      context "when status does not change" do
        it "does not enqueue status processor job" do
          waitlist = create(:waitlist, status: :approved)
          expect {
            waitlist.update!(status: :approved)
          }.not_to have_enqueued_job(WaitlistStatusProcessorJob)
        end
      end
    end
  end

  describe "#user_location" do
    let(:waitlist) { create(:waitlist, city: "New York", country: "US") }

    it "returns formatted location string" do
      expect(waitlist.user_location).to eq("New York, The United States of America")
    end

    context "when city is missing" do
      let(:waitlist) { create(:waitlist, city: nil, country: "US") }

      it "returns only country" do
        expect(waitlist.user_location).to eq("The United States of America")
      end
    end

    context "when country is missing" do
      let(:waitlist) { create(:waitlist, city: "New York", country: nil) }

      it "returns only city" do
        expect(waitlist.user_location).to eq("New York")
      end
    end

    context "when both city and country are missing" do
      let(:waitlist) { create(:waitlist, city: nil, country: nil) }

      it "returns empty string" do
        expect(waitlist.user_location).to eq("")
      end
    end
  end
end
