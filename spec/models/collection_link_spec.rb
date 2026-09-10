require "rails_helper"

RSpec.describe CollectionLink, type: :model do
  let(:user) { build(:user) }
  let(:collection) { build(:collection, user:) }
  let(:collection_link) { build(:collection_link, collection:, user:) }

  describe "enums" do
    context "status" do
      it "has the correct values" do
        expect(CollectionLink.statuses).to eq({"public" => 0, "private" => 1, "paid" => 2})
      end
    end
  end

  describe "validations" do
    it "validates the uniqueness of the collection link" do
      expect(collection_link).to be_valid
    end

    context "when a public link already exists for the collection" do
      it "is invalid if trying to create another public link" do
        create(:collection_link, collection: collection, user: user, status: :public)
        new_public_link = build(:collection_link, collection: collection, user: user, status: :public)

        expect(new_public_link).not_to be_valid
        expect(new_public_link.errors[:status]).to include("collection already has a public link")
      end
    end

    context "when a private link already exists for the collection" do
      it "is invalid if trying to create another private link" do
        create(:collection_link, collection: collection, user: user, status: :private)
        new_private_link = build(:collection_link, collection: collection, user: user, status: :private)

        expect(new_private_link).not_to be_valid
        expect(new_private_link.errors[:status]).to include("collection already has a private link")
      end
    end

    context "when creating links of different types" do
      it "allows creating one of each type" do
        public_link = create(:collection_link, collection: collection, user: user, status: :public)
        private_link = build(:collection_link, collection: collection, user: user, status: :private)
        paid_link = build(:collection_link, collection: collection, user: user, status: :paid)

        expect(public_link).to be_valid
        expect(private_link).to be_valid
        expect(paid_link).to be_valid
      end
    end
  end

  describe "callbacks" do
    it "generates a link before creation" do
      collection_link.save

      expect(collection_link.link).to be_present
      expect(collection_link.link.length).to eq(7)
    end

    it "snapshots the collection before creation" do
      allow(Collections::SnapshotService).to receive_message_chain(:new, :call).and_return("snapshot_data")
      collection_link.save

      expect(collection_link.collection_data).to eq("snapshot_data")
    end
  end

  describe "#collection_link_url" do
    it "returns the correct url" do
      expect(collection_link.collection_link_url).to eq("http://example.com/c/#{collection_link.link}")
    end
  end

  describe "#save_view!" do
    before do
      collection_link.save
    end

    it "increments the views count" do
      expect { collection_link.save_view! }.to change(collection_link, :views_count).by(1)
    end
  end
end
