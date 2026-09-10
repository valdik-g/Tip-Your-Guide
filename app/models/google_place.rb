class GooglePlace < ApplicationRecord
  belongs_to :place

  validates :external_id, presence: true, uniqueness: {scope: :place_id}

  def converted_price_level
    PriceLevel.new(google_price_level: metadata["price_level"]).to_i
  end
end
