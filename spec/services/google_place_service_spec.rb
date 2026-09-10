require "rails_helper"

RSpec.describe GooglePlaceService do
  let(:place) { build(:place, id: 123, title: "Golden Gate Bridge") }
  let(:google_place) { build(:google_place, place: place, external_id: "ChIJ2aPIrX-EhYARCnGUgT7g0vU") }
  let(:api_key) { "fake-api-key" }
  let(:mock_client) { instance_double(Google::Apis::PlacesV1::MapsPlacesService) }
  let(:service) { described_class.new }
  let(:text_fields) { "places.name" }
  let(:name_fields) { "short_formatted_address,display_name,google_maps_links,location,international_phone_number,website_uri,types,rating,primary_type,price_level,photos" }

  before do
    allow(Google::Apis::PlacesV1::MapsPlacesService).to receive(:new).and_return(mock_client)
    allow(mock_client).to receive(:key=).with(api_key)
    stub_const("ENV", ENV.to_hash.merge("GOOGLE_PLACES_API_KEY" => api_key))
    allow(PosthogClient).to receive(:capture)
  end

  describe "#initialize" do
    it "creates a new Google Places client with API key" do
      expect(Google::Apis::PlacesV1::MapsPlacesService).to receive(:new)
      expect(mock_client).to receive(:key=).with(api_key)
      described_class.new
    end
  end

  describe "#fetch_by_text" do
    context "when the API call is successful" do
      let(:mock_request) { instance_double(Google::Apis::PlacesV1::GoogleMapsPlacesV1SearchTextRequest) }
      let(:mock_response) { double("response") }
      let(:google_place_data) { {id: "place123", name: "Golden Gate Bridge"} }

      before do
        allow(Google::Apis::PlacesV1::GoogleMapsPlacesV1SearchTextRequest).to receive(:new)
          .with(text_query: "Golden Gate Bridge Barcelona Spain")
          .and_return(mock_request)

        allow(mock_client).to receive(:search_place_text)
          .with(mock_request, fields: text_fields)
          .and_return(mock_response)

        allow(mock_response).to receive(:to_h)
          .and_return({places: [google_place_data]})
      end

      it "calls the Google Places API with correct parameters" do
        expect(mock_client).to receive(:search_place_text).with(mock_request, fields: text_fields)
        service.fetch_by_text(place)
      end

      it "returns the first place from the response" do
        result = service.fetch_by_text(place)
        expect(result).to eq(google_place_data)
      end

      context "with custom fields" do
        let(:text_fields) { "places.id,places.displayName" }

        it "accepts custom fields parameter" do
          expect(mock_client).to receive(:search_place_text).with(mock_request, fields: text_fields)
          service.fetch_by_text(place, text_fields)
        end
      end
    end

    context "when the API call fails" do
      let(:error_message) { Google::Apis::ClientError.new("API Error") }

      before do
        allow(mock_client).to receive(:search_place_text).and_raise(error_message)
      end

      it "rescues the exception and logs failure" do
        expect(PosthogClient).to receive(:capture).with(
          {
            event: "google_place_fetch",
            distinct_id: place.id,
            properties: {
              type: "by_text",
              status: "failure",
              text_query: "Golden Gate Bridge Barcelona Spain",
              message: "API Error"
            }
          }
        )

        expect { service.fetch_by_text(place) }.not_to raise_error
      end
    end
  end

  describe "#fetch_by_name" do
    context "when the API call is successful" do
      let(:mock_response) { double("response") }
      let(:place_details) { {name: "Golden Gate Bridge", rating: 4.8} }

      before do
        allow(mock_client).to receive(:get_place)
          .with(google_place.external_id, fields: name_fields)
          .and_return(mock_response)

        allow(mock_response).to receive(:to_h)
          .and_return(place_details)
      end

      it "calls the Google Places API with correct parameters" do
        expect(mock_client).to receive(:get_place).with(google_place.external_id, fields: name_fields)
        service.fetch_by_name(google_place)
      end

      it "returns the place details from the response" do
        result = service.fetch_by_name(google_place)
        expect(result).to eq(place_details)
      end

      context "with custom fields" do
        let(:custom_fields) { "name,photos,editorial_summary" }

        it "accepts custom fields parameter" do
          expect(mock_client).to receive(:get_place).with(google_place.external_id, fields: custom_fields)
          service.fetch_by_name(google_place, custom_fields)
        end
      end
    end

    context "when the API call fails" do
      let(:error_message) { Google::Apis::ClientError.new("API Error") }

      before do
        allow(mock_client).to receive(:get_place).and_raise(error_message)
      end

      it "rescues the exception and logs failure" do
        expect(PosthogClient).to receive(:capture).with(
          {
            event: "google_place_fetch",
            distinct_id: google_place.place.id,
            properties: {
              type: "by_name",
              status: "failure",
              message: "API Error"
            }
          }
        )

        expect { service.fetch_by_name(google_place) }.not_to raise_error
      end
    end
  end

  describe "#fetch_place_photo_url" do
    let(:photo_name) { "places/ChIJ2aPIrX-EhYARCnGUgT7g0vU/photos/AUy1YQ2PBlMXnPiwZKIFQ4D-WvRAqeNv96HLl688RcuT7SCSP2cT65p6H-R0DdB-bRN3zjXu7OopjKrkNA9j_fDfWCnSN845_slAbBuYDVH8cAWrndcPz67MeEXPwDpShh3sUiTj2mU2BTfWZj9x9IOhuNNLywArYnISh0M8Jc2dbPCxIVeGPYTjag51HyIO8MZr0cj8fy0YpumC2mXCLqLWFpgSWfAcTracjeMYKB9AgScV77smqueNbX2H7ya8ymkvQDttKTzj44BZ-tZ03xljKqq5iHMai9uCcWw-8maTJWCZZw/media" }
    let(:photo_uri) { "https://example.com/photo.jpg" }

    context "when the API call is successful" do
      let(:mock_response) { double("response", photo_uri: photo_uri) }

      before do
        allow(mock_client).to receive(:get_place_photo_media)
          .with(photo_name, max_height_px: nil, max_width_px: nil, skip_http_redirect: true)
          .and_return(mock_response)
      end

      it "calls the Google Places API with correct parameters" do
        expect(mock_client).to receive(:get_place_photo_media)
          .with(photo_name, max_height_px: nil, max_width_px: nil, skip_http_redirect: true)
        service.fetch_place_photo_url(name: photo_name)
      end

      it "returns the photo URI from the response" do
        result = service.fetch_place_photo_url(name: photo_name)
        expect(result).to eq(photo_uri)
      end
    end

    context "when the API call fails" do
      let(:error_message) { Google::Apis::ClientError.new("API Error") }

      before do
        allow(mock_client).to receive(:get_place_photo_media).and_raise(error_message)
      end

      it "rescues the exception and logs failure" do
        expect(PosthogClient).to receive(:capture).with(
          {
            event: "download_place_photo",
            distinct_id: photo_name,
            properties: {
              status: "failure",
              message: "API Error"
            }
          }
        )

        expect { service.fetch_place_photo_url(name: photo_name) }.not_to raise_error
      end
    end
  end
end
