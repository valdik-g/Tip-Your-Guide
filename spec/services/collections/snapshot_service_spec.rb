require "rails_helper"

RSpec.describe Collections::SnapshotService, type: :service do
  let(:collection) { build(:collection) }
  let(:snapshot_service) { described_class.new(collection) }

  describe "#call" do
    let(:places_data) { [{"name" => "Place 1"}, {"name" => "Place 2"}] }
    let(:collection_data) { {"name" => "Collection Name"} }

    before do
      allow(collection).to receive(:as_json).and_return(collection_data)
      allow(collection).to receive_message_chain(:places, :as_json).and_return(places_data)
    end

    it "returns collection data with places" do
      result = snapshot_service.call
      expect(result).to eq(collection_data.merge("places" => places_data))
    end
  end
end
