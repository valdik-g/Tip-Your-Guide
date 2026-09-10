class Collections::CardComponent < ApplicationComponent
  def initialize(collection:, paid_link:)
    @collection = collection
    @paid_link = paid_link
  end

  def title
    collection.title
  end

  def places_count
    t("guides.show.collection.places_count", count: collection.places.count)
  end

  def description
    collection.description&.to_plain_text
  end

  def has_description?
    collection.description.present?
  end

  def requires_payment?
    return false if show_paid_link_for_free?
    return false if collection.public_status?
    return true if session[:purchased].blank?

    paid_link.blank?
  end

  def show_paid_link_for_free?
    # if the collection is not for purchase, skip this check
    return false unless collection.paid_status?

    # admins can see the paid link for free
    return true if current_user&.is_admin?

    # owners can see the paid link for free
    return true if collection.user_id == current_user&.id

    false
  end

  def user_paid_for_collection?
    # if the collection is not for purchase, skip this check
    return false if collection.public_status?

    # if the paid link is present and paid, return true
    return true if paid_link&.paid_status?

    # if the paid link is in the session, return true
    session[:purchased]&.include?(paid_link&.id)
  end

  def collection_link_url
    # if the collection is public, return the public link url
    return public_link_url unless collection.paid_status?

    # if the collection is paid and requires payment, return the checkout path
    return checkout_collections_purchases_path(collection_id: collection.id) if requires_payment?

    # if the collection is paid and the user has paid for it, return the paid link url
    paid_link.collection_link_url
  end

  def public_link_url
    collection_url(id: collection.id)
  end

  def no_links_message
    t("guides.show.collection.no_links")
  end

  def collection_card_image(collection)
    if collection.thumbnail.attached?
      url_for(collection.thumbnail)
    else
      Rails.cache.fetch("collection_card_#{collection.id}", expires_in: 1.month) do
        Unsplash::Photo.random(query: collection.title, count: 1).first.urls.regular
      rescue Unsplash::Error
        nil
      end
    end
  end

  private

  attr_reader :collection, :paid_link
end
