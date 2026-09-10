# frozen_string_literal: true

class CollectionLinks::CardComponent < ApplicationComponent
  def initialize(collection_link:)
    @link = collection_link
  end
end
