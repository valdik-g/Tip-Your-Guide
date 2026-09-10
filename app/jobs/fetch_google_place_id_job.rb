class FetchGooglePlaceIdJob < ApplicationJob
  queue_as :default

  def perform(place_id)
    place = Place.find_by(id: place_id)
    return unless place
    return if GooglePlace.exists?(place_id: place_id)
    return unless GooglePlaceService.configured?

    google_place_service = GooglePlaceService.new
    google_place_data = google_place_service.fetch_by_text(place)

    return unless google_place_data

    google_place = GooglePlace.create!(
      place: place,
      external_id: google_place_data[:name]
    )

    FetchGooglePlaceMetadataJob.perform_later(google_place.id)
  end
end
