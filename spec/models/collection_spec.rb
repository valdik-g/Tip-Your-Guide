require "rails_helper"

RSpec.describe Collection, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:collection_places).dependent(:destroy) }
    it { is_expected.to have_many(:places).through(:collection_places) }
    it { is_expected.to have_many(:collection_links).dependent(:nullify) }
  end

  describe "scopes" do
    let(:user) { create(:user, :guide) }

    describe ".published" do
      it "returns collections that are not in draft status" do
        draft_collection = create(:collection, user:, status: :draft)
        public_collection = create(:collection, user:, status: :public)

        expect(Collection.published).to include(public_collection)
        expect(Collection.published).not_to include(draft_collection)
      end
    end
  end

  describe "#already_purchased?" do
    let(:user) { create(:user, :guide) }
    let(:collection) { create(:collection, user:) }
    let(:session_purchases) { ["link_1"] }

    context "when a matching paid collection link exists" do
      let!(:paid_link) { create(:collection_link, collection: collection, user:, link: "link1", status: :paid) }
      let(:session_purchases) { [paid_link.link] }

      it "returns true" do
        expect(collection.already_purchased?(session_purchases: session_purchases)).to be true
      end
    end

    context "when no matching paid collection link exists" do
      before do
        create(:collection_link, collection: collection, user:, status: :paid)
      end

      it "returns false" do
        expect(collection.already_purchased?(session_purchases: session_purchases)).to be false
      end
    end
  end
end
