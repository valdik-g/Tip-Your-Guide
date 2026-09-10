class PaymentInfo < ApplicationRecord
  belongs_to :user
  has_many :payments, dependent: :nullify

  enum :charge_type, {
    donation_purchase: 0,
    collection_purchase: 1
  }

  validates :charge_type, presence: true
  validates :stripe_product_id, presence: true

  scope :donation_purchase, -> { where(charge_type: :donation_purchase) }
  scope :collection_purchase, -> { where(charge_type: :collection_purchase) }

  def display_name
    case charge_type
    when "donation_purchase" then "Tips"
    when "collection_purchase" then "Collection"
    end
  end
end
