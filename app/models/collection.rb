class Collection < ApplicationRecord
  include HeicToJpeg

  belongs_to :user

  has_one :collection_price, class_name: "Collection::Price", dependent: :nullify

  has_many :collection_places, dependent: :destroy
  has_many :places, through: :collection_places, inverse_of: :collections
  has_many :collection_links, dependent: :nullify
  has_many :paid_collection_links, -> { paid_status }, class_name: "CollectionLink", dependent: :nullify

  has_one_attached :thumbnail
  heic_convertible_for :thumbnail

  has_rich_text :description

  accepts_nested_attributes_for :collection_price, update_only: true

  after_create :create_paid_link

  scope :published, -> { where.not(status: :draft) }

  enum :status, {
    draft: 0,
    public: 1,
    paid: 2
  }, suffix: true

  # store the paid link in the database to let admins and guides to see the content without having to purchase it
  def create_paid_link
    collection_links.create!(status: :paid, user: user)
  end

  def already_purchased?(session_purchases:)
    collection_links.paid_status.where(link: session_purchases).exists?
  end
end
