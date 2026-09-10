require "rails_helper"

RSpec.describe Place, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:collection_places) }
    it { is_expected.to have_many(:collections).through(:collection_places) }
    it { is_expected.to have_one(:google_place).dependent(:destroy) }
  end

  describe "callbacks" do
    describe "#schedule_google_place_fetch" do
      it "schedules FetchGooglePlaceIdJob after creation" do
        user = create(:user)
        expect {
          create(:place, user: user)
        }.to have_enqueued_job(FetchGooglePlaceIdJob)
      end
    end
  end

  describe "#description" do
    it "returns the default description" do
      place = build(:place)
      expect(place.description.to_plain_text).to eq("This is a test place")
    end
  end
end
