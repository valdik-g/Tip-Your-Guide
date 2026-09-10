class Guides::Profile::CollectionsComponent < ApplicationComponent
  def initialize(collections:, paid_links:)
    @collections = collections
    @paid_links = paid_links
  end

  def empty?
    collections.blank?
  end

  def empty_state_title
    t("guides.show.empty_state.title")
  end

  def empty_state_description
    t("guides.show.empty_state.description")
  end

  # paid_links here is a hash of collection_id => paid_link if present
  def paid_link_for(collection:)
    paid_links[collection.id]
  end

  private

  attr_reader :collections, :paid_links
end
