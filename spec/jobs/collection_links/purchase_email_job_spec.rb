require "rails_helper"

RSpec.describe CollectionLinks::PurchaseEmailJob, type: :job do
  let(:user) { create(:user) }
  let(:collection) { create(:collection, user:) }
  let!(:collection_link) { create(:collection_link, user:, collection:) }
  let(:stripe_checkout_session_id) { "cs_test_123" }
  let(:customer_email) { "test@example.com" }
  let(:stripe_checkout_session) do
    Stripe::Checkout::Session.construct_from({
      id: stripe_checkout_session_id,
      customer_details: {
        email: customer_email
      }
    })
  end

  before do
    allow(Stripe::Checkout::Session).to receive(:retrieve).with(stripe_checkout_session_id).and_return(stripe_checkout_session)
  end

  describe "#perform" do
    context "when customer email is present" do
      it "sends a purchase email" do
        expect(CollectionLinkMailer).to receive(:purchased).with(
          collection_link:,
          customer_email:
        ).and_call_original

        described_class.new.perform(collection_link_id: collection_link.id, stripe_checkout_session_id:)
      end
    end

    context "when customer email is blank" do
      let(:customer_email) { "" }

      it "does not send a purchase email" do
        expect(CollectionLinkMailer).not_to receive(:purchased)

        described_class.new.perform(collection_link_id: collection_link.id, stripe_checkout_session_id:)
      end
    end
  end
end
