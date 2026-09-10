module Collections
  class UpsertService
    class CollectionPriceParams
      def initialize(collection_price_attributes)
        @collection_price_attributes = collection_price_attributes
      end

      def to_attributes
        {
          id: collection_price_attributes[:id],
          stripe_id: collection_price_attributes[:stripe_id],
          price: collection_price_attributes[:price],
          currency: collection_price_attributes[:currency]
        }
      end

      private

      attr_reader :collection_price_attributes
    end
  end
end
