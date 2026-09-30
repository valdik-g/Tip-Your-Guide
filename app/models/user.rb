class User < ApplicationRecord
  include HeicToJpeg

  rolify

  has_secure_password

  has_one_attached :avatar
  heic_convertible_for :avatar

  generates_token_for :password_reset, expires_in: 1.day do
    # Last 10 characters of password salt, which changes when password is updated:
    password_salt&.last(10)
  end

  has_many :sessions, dependent: :destroy
  has_many :places, dependent: :nullify
  has_many :collections, dependent: :nullify
  has_many :payments, dependent: :nullify

  # Associated paid products
  has_many :payment_infos
  has_one :collection_purchase_payment_info, -> { collection_purchase }, class_name: "PaymentInfo", dependent: :destroy

  has_one :waitlist, dependent: :destroy

  has_one :subscription, dependent: :destroy

  has_many :blog_posts, foreign_key: :author_id, dependent: :nullify

  before_validation :generate_slug, on: :create

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, on: :create
  validates :full_name, presence: true
  validates :country, presence: true
  validates :city, presence: true
  validates :avatar, content_type: ["image/png", "image/jpeg", "image/heic", "image/heif"], size: {less_than: 5.megabytes}

  def masqueradable?
    has_role?(:guide) && !has_role?(:admin)
  end

  def is_guide?
    has_role?(:guide)
  end

  def is_admin?
    has_role?(:admin)
  end

  def to_param
    slug
  end

  def has_active_subscription?
    subscription&.accessible? || false
  end

  private

  def generate_slug
    return if slug.present?

    base_slug = full_name.parameterize
    self.slug = base_slug

    # Handle slug collisions by appending a number if needed
    counter = 2
    while User.exists?(slug: slug)
      self.slug = "#{base_slug}-#{counter}"
      counter += 1
    end
  end
end
