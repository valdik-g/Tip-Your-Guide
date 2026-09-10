require "rails_helper"

RSpec.describe FetchGooglePlaceMetadataJob, type: :job do
  let(:place) { create(:place, id: 123, title: "Golden Gate Bridge") }
  let(:google_place) { create(:google_place, id: 456, place: place, external_id: "ChIJ2aPIrX-EhYARCnGUgT7g0vU") }
  let(:google_place_service) { instance_double(GooglePlaceService) }

  before do
    allow(GooglePlaceService).to receive(:new).and_return(google_place_service)
  end

  describe "#perform" do
    context "when GooglePlace doesn't exist" do
      before do
        allow(GooglePlace).to receive(:find_by).with(id: 999).and_return(nil)
      end

      it "does nothing" do
        expect(google_place_service).not_to receive(:fetch_by_name)
        described_class.perform_now(999)
      end
    end

    context "when GooglePlaceService doesn't find place data" do
      before do
        allow(GooglePlace).to receive(:find_by).with(id: 456).and_return(google_place)
        allow(google_place_service).to receive(:fetch_by_name).with(google_place).and_return(nil)
      end

      it "doesn't update the GooglePlace" do
        expect(google_place).not_to receive(:update!)
        described_class.perform_now(456)
      end
    end

    context "when GooglePlaceService finds place data" do
      let(:photos) { nil }
      let(:place_data) { {name: "Golden Gate Bridge", rating: 4.8, international_phone_number: "+1 415-123-4567", photos:} }

      before do
        allow(GooglePlace).to receive(:find_by).with(id: 456).and_return(google_place)
        allow(google_place_service).to receive(:fetch_by_name).with(google_place).and_return(place_data)
      end

      it "updates the GooglePlace with the metadata" do
        expect(google_place).to receive(:update!).with(metadata: place_data)
        described_class.perform_now(456)
      end

      context "when photos data is present" do
        let(:photos) do
          [
            {
              author_attributions: [
                {
                  display_name: "Vermuteria la Cova de la Mari",
                  photo_uri: "https://lh3.googleusercontent.com/a-/ALV-UjVtvpGvaWr3ZgPBgTJJTxohtUWgYa-HGmePryzuyIh8YZqOnN0=s100-p-k-no-mo",
                  uri: "https://maps.google.com/maps/contrib/116472020680156187419"
                }
              ],
              flag_content_uri: "https://www.google.com/local/imagery/report/?cb_client=maps_api_places.places_api&image_key=!1e10!2sAF1QipMhFphJV6Z7Z2j1LsjcyzZ4V3dJqiunV1iBJFxE&hl=en-US",
              google_maps_uri: "https://www.google.com/maps/place//data=!3m4!1e2!3m2!1sAF1QipMhFphJV6Z7Z2j1LsjcyzZ4V3dJqiunV1iBJFxE!2e10!4m2!3m1!1s0x12a4a3ebfa805553:0x1693e205846af22e",
              height_px: 607,
              name: "places/ChIJU1WA-uujpBIRLvJqhAXikxY/photos/AUy1YQ2PBlMXnPiwZKIFQ4D-WvRAqeNv96HLl688RcuT7SCSP2cT65p6H-R0DdB-bRN3zjXu7OopjKrkNA9j_fDfWCnSN845_slAbBuYDVH8cAWrndcPz67MeEXPwDpShh3sUiTj2mU2BTfWZj9x9IOhuNNLywArYnISh0M8Jc2dbPCxIVeGPYTjag51HyIO8MZr0cj8fy0YpumC2mXCLqLWFpgSWfAcTracjeMYKB9AgScV77smqueNbX2H7ya8ymkvQDttKTzj44BZ-tZ03xljKqq5iHMai9uCcWw-8maTJWCZZw",
              width_px: 1080
            },
            {
              author_attributions: [
                {
                  display_name: "Vermuteria la Cova de la Mari",
                  photo_uri: "https://lh3.googleusercontent.com/a-/ALV-UjVtvpGvaWr3ZgPBgTJJTxohtUWgYa-HGmePryzuyIh8YZqOnN0=s100-p-k-no-mo",
                  uri: "https://maps.google.com/maps/contrib/116472020680156187419"
                }
              ],
              flag_content_uri: "https://www.google.com/local/imagery/report/?cb_client=maps_api_places.places_api&image_key=!1e10!2sAF1QipOAo-NaUEvvboAxBxeBi5xTl2ZNJWFvBfx0OWwv&hl=en-US",
              google_maps_uri: "https://www.google.com/maps/place//data=!3m4!1e2!3m2!1sAF1QipOAo-NaUEvvboAxBxeBi5xTl2ZNJWFvBfx0OWwv!2e10!4m2!3m1!1s0x12a4a3ebfa805553:0x1693e205846af22e",
              height_px: 607,
              name: "places/ChIJU1WA-uujpBIRLvJqhAXikxY/photos/AUy1YQ0TmGVzHr9DFvzjx9lJqa7ifI2B6jPPVeuRcmxJpjyz9otwqKdBFSjYuxV4yby3c7eUXtU1qq49Siunef7QOp8onmGMChZ1AsbQnICT1ECAEDvUB4pWXOAZASRgzXPZL2BXX9FroMYnw7QVxNtii2Ua2OTeok37g4YKIdfvh41ObBYE3rt9Si6IvbmB-zDf2l85-OWVClyepISClw3x3cqQokIsrCgLJa4xl2TKKGeUV_392ChWtei_nGVP6BKn5bmZlqqw-m1Bqxys-qzSs2o3BX_2DRUpxas9KSacpY7zHA",
              width_px: 1080
            }
          ]
        end

        before do
          expect(google_place_service).to receive(:fetch_place_photo_url).with(name: photos.first[:name], max_width_px: 300).and_return("image.url")
        end

        it "updates the GooglePlace with the metadata and photo URI" do
          expected_data = place_data.slice(:name, :rating, :international_phone_number).merge(photo_uri: "image.url", photo_name: photos.first[:name])
          expect(google_place).to receive(:update!).with(metadata: expected_data)
          described_class.perform_now(456)
        end
      end
    end

    context "when GooglePlace update fails" do
      let(:place_data) { {name: "Golden Gate Bridge", rating: 4.8, location: {lat: 37.8199, lng: -122.4783}} }

      before do
        allow(GooglePlace).to receive(:find_by).with(id: 456).and_return(google_place)
        allow(google_place_service).to receive(:fetch_by_name).with(google_place).and_return(place_data)
        allow(google_place).to receive(:update!).and_raise(ActiveRecord::RecordInvalid)
      end

      it "raises the exception" do
        expect { described_class.perform_now(456) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "when the GooglePlaceService raises an error" do
      before do
        allow(GooglePlace).to receive(:find_by).with(id: 456).and_return(google_place)
        allow(google_place_service).to receive(:fetch_by_name).with(google_place).and_raise(StandardError, "API error")
      end

      it "allows the error to propagate" do
        expect { described_class.perform_now(456) }.to raise_error(StandardError, "API error")
      end
    end
  end
end
