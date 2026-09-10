class FetchGooglePlaceMetadataJob < ApplicationJob
  queue_as :default

  attr_reader :google_place_service, :google_place_data

  def perform(google_place_id)
    return unless GooglePlaceService.configured?
    google_place = GooglePlace.find_by(id: google_place_id)
    return unless google_place

    @google_place_service = GooglePlaceService.new
    @google_place_data = google_place_service.fetch_by_name(google_place)

    return unless @google_place_data

    maybe_extract_photo_url!
    google_place.update!(metadata: @google_place_data)
  end

  def maybe_extract_photo_url!
    photos = @google_place_data.delete(:photos)
    return if photos.blank?

    photo_name = photos.first[:name]
    photo_uri = google_place_service.fetch_place_photo_url(name: photo_name, max_width_px: 300)
    @google_place_data.merge!(photo_uri:, photo_name:)
  end
end
