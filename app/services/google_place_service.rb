require "google/apis/places_v1"

class GooglePlaceService
  FETCH_BY_TEXT_FIELDS = "places.name"
  FETCH_BY_NAME_FIELDS = "short_formatted_address,display_name,google_maps_links,location,international_phone_number,website_uri,types,rating,primary_type,price_level,photos"

  # Configured from the environment in this sandbox:
  #
  #   export GOOGLE_PLACES_API_KEY=...
  #
  # Without a key the service reports itself as unconfigured and the jobs that
  # use it return early, so the app seeds and runs fine without Google access.
  def self.configured?
    ENV["GOOGLE_PLACES_API_KEY"].present?
  end

  def initialize
    @client = Google::Apis::PlacesV1::MapsPlacesService.new
    @client.key = ENV["GOOGLE_PLACES_API_KEY"]
  end

  def fetch_by_text(place, fields = FETCH_BY_TEXT_FIELDS)
    text_query = "#{place.title} #{place.user.city} #{ISO3166::Country[place.user.country]&.iso_short_name}"
    request_object = Google::Apis::PlacesV1::GoogleMapsPlacesV1SearchTextRequest.new(text_query:)
    response = @client.search_place_text(request_object, fields:)
    response.to_h[:places][0]
  rescue Google::Apis::ClientError => message
    PosthogClient.capture({
      event: "google_place_fetch",
      distinct_id: place.id,
      properties: {
        type: "by_text",
        status: "failure",
        text_query:,
        message: message.to_s
      }
    })
  end

  def fetch_by_name(google_place, fields = FETCH_BY_NAME_FIELDS)
    google_place_name = google_place.external_id
    response = @client.get_place(google_place_name, fields:)
    response.to_h
  rescue Google::Apis::ClientError => message
    PosthogClient.capture({
      event: "google_place_fetch",
      distinct_id: google_place.place.id,
      properties: {
        type: "by_name",
        status: "failure",
        message: message.to_s
      }
    })
  end

  def fetch_place_photo_url(name:, max_height_px: nil, max_width_px: nil)
    photo_name = name.ends_with?("/media") ? name : "#{name}/media"
    response = @client.get_place_photo_media(photo_name, max_height_px:, max_width_px:, skip_http_redirect: true)
    response.photo_uri
  rescue Google::Apis::ClientError => message
    PosthogClient.capture({
      event: "download_place_photo",
      distinct_id: name,
      properties: {
        status: "failure",
        message: message.to_s
      }
    })
  end

  private

  attr_reader :client
end
