# frozen_string_literal: true

module Places
  class CardComponent < ApplicationComponent
    include RatingStarsHelper

    with_collection_parameter :place

    attr_reader :place, :google_place

    def initialize(place:)
      @place = place
      @google_place = place.google_place
    end

    def rating
      return unless google_place

      google_place.metadata["rating"]
    end

    def price_level
      return unless google_place

      google_place.converted_price_level
    end

    def photo_url
      if place.photo.attached?
        place.photo.variant(resize_to_limit: [600, 600]).processed
      elsif google_place&.metadata&.dig("photo_uri").present?
        google_place.metadata["photo_uri"]
      end
    end

    def external_url
      if place.url.present?
        place.url.start_with?("http") ? place.url : "https://#{place.url}"
      elsif google_place&.metadata&.dig("website_uri").present?
        google_place.metadata["website_uri"]
      end
    end

    def address
      return unless google_place

      google_place.metadata["short_formatted_address"]
    end
  end
end
