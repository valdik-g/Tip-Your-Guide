class Place < ApplicationRecord
  include HeicToJpeg

  belongs_to :user

  has_many :collection_places
  has_many :collections, through: :collection_places
  has_one :google_place, dependent: :destroy

  after_create :schedule_google_place_fetch

  has_rich_text :description

  has_one_attached :photo
  heic_convertible_for :photo

  def schedule_google_place_fetch
    FetchGooglePlaceIdJob.perform_later(id)
  end
end
