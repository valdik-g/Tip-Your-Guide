require "rails_helper"

RSpec.describe GooglePlace, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:place) }
  end

  describe "validations" do
    subject { create(:google_place) }

    it { is_expected.to validate_presence_of(:external_id) }
    it { is_expected.to validate_uniqueness_of(:external_id).scoped_to(:place_id) }
  end

  describe "#converted_price_level" do
    context "when price level is present" do
      let(:google_place) { create(:google_place, metadata: {"price_level" => "PRICE_LEVEL_MODERATE"}) }

      it "returns the correct price level" do
        expect(google_place.converted_price_level).to eq(2)
      end
    end

    context "when price level is not present" do
      let(:google_place) { create(:google_place, metadata: {}) }

      it "returns -1" do
        expect(google_place.converted_price_level).to eq(-1)
      end
    end
  end
end
