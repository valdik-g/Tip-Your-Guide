require "rails_helper"

RSpec.describe FetchGooglePlaceIdJob, type: :job do
  let(:place) { create(:place, id: 123, title: "Golden Gate Bridge") }
  let(:google_place_service) { instance_double(GooglePlaceService) }

  before do
    allow(GooglePlaceService).to receive(:new).and_return(google_place_service)
  end

  describe "#perform" do
    context "when Place doesn't exist" do
      before do
        allow(Place).to receive(:find_by).with(id: 456).and_return(nil)
      end

      it "does nothing" do
        expect(GooglePlace).not_to receive(:exists?)
        described_class.perform_now(456)
      end
    end

    context "when GooglePlace already exists for the place" do
      before do
        allow(Place).to receive(:find_by).with(id: 123).and_return(place)
        allow(GooglePlace).to receive(:exists?).with(place_id: 123).and_return(true)
      end

      it "doesn't call the GooglePlaceService" do
        expect(google_place_service).not_to receive(:fetch_by_text)
        described_class.perform_now(123)
      end
    end

    context "when GooglePlaceService doesn't find place data" do
      before do
        allow(Place).to receive(:find_by).with(id: 123).and_return(place)
        allow(GooglePlace).to receive(:exists?).with(place_id: 123).and_return(false)
        allow(google_place_service).to receive(:fetch_by_text).with(place).and_return(nil)
      end

      it "doesn't create a GooglePlace" do
        expect(GooglePlace).not_to receive(:create!)
        described_class.perform_now(123)
      end
    end

    context "when GooglePlaceService finds place data" do
      let(:google_place_data) { {id: "place123", name: "ChIJ2aPIrX-EhYARCnGUgT7g0vU"} }
      let(:google_place) { instance_double(GooglePlace, id: 42) }

      before do
        allow(Place).to receive(:find_by).with(id: 123).and_return(place)
        allow(GooglePlace).to receive(:exists?).with(place_id: 123).and_return(false)
        allow(google_place_service).to receive(:fetch_by_text).with(place).and_return(google_place_data)
        allow(GooglePlace).to receive(:create!).and_return(google_place)
        allow(FetchGooglePlaceMetadataJob).to receive(:perform_later)
      end

      it "creates a GooglePlace with the correct attributes" do
        expect(GooglePlace).to receive(:create!).with(
          place: place,
          external_id: "ChIJ2aPIrX-EhYARCnGUgT7g0vU"
        )
        described_class.perform_now(123)
      end

      it "enqueues a FetchGooglePlaceMetadataJob with the new GooglePlace id" do
        expect(FetchGooglePlaceMetadataJob).to receive(:perform_later).with(42)
        described_class.perform_now(123)
      end
    end

    context "when GooglePlace creation fails" do
      let(:google_place_data) { {id: "place123", name: "ChIJ2aPIrX-EhYARCnGUgT7g0vU"} }

      before do
        allow(Place).to receive(:find_by).with(id: 123).and_return(place)
        allow(GooglePlace).to receive(:exists?).with(place_id: 123).and_return(false)
        allow(google_place_service).to receive(:fetch_by_text).with(place).and_return(google_place_data)
        allow(GooglePlace).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
      end

      it "raises the exception" do
        expect { described_class.perform_now(123) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "when the GooglePlaceService raises an error" do
      before do
        allow(Place).to receive(:find_by).with(id: 123).and_return(place)
        allow(GooglePlace).to receive(:exists?).with(place_id: 123).and_return(false)
        allow(google_place_service).to receive(:fetch_by_text).with(place).and_raise(StandardError, "API error")
      end

      it "allows the error to propagate" do
        expect { described_class.perform_now(123) }.to raise_error(StandardError, "API error")
      end
    end
  end
end
