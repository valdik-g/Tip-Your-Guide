module Collections
  module Prices
    class SyncToProviderJob < ApplicationJob
      def perform(collection_price_id:)
        collection_price = Collection::Price.find(collection_price_id)
        Collections::Prices::SyncToProviderService.new(collection_price:).call
      end
    end
  end
end
