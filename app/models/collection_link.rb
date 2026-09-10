class CollectionLink < ApplicationRecord
  # TODO: currently not used as we don't have other common users - will add later
  belongs_to :user
  belongs_to :collection

  enum :status, {
    public: 0,
    private: 1,
    paid: 2
  }, suffix: true

  before_create :generate_link
  before_create :snapshot_collection

  validate :validate_collection_link_uniqueness, on: :create

  def collection_link_url
    Rails.application.routes.url_helpers.short_collection_link_url(link)
  end

  def save_view!
    increment!(:views_count)
  end

  private

  def generate_link
    self.link = SecureRandom.urlsafe_base64(5)
  end

  def snapshot_collection
    return if collection_data.present?

    self.collection_data = Collections::SnapshotService.new(collection).call
  end

  def validate_collection_link_uniqueness
    if public_status? && collection.collection_links.public_status.exists?
      errors.add(:status, "collection already has a public link")
    elsif private_status? && collection.collection_links.private_status.exists?
      errors.add(:status, "collection already has a private link")
    end
  end
end
