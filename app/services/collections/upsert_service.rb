module Collections
  class UpsertService
    attr_reader :id, :title, :user_id, :status, :place_ids, :description,
      :collection_price_attributes, :thumbnail

    def initialize(title:, description:, user_id:, status:, collection_price_attributes:, id: nil, thumbnail: nil, place_ids: nil)
      @id = id
      @title = title
      @user_id = user_id
      @status = status
      @place_ids = place_ids
      @thumbnail = thumbnail
      @description = description
      @collection_price_attributes = CollectionPriceParams.new(collection_price_attributes)
    end

    def call
      Collection.transaction do
        collection = id.present? ? update_collection : create_collection
        Collection.reset_counters(collection.id, :places)

        if collection.paid_status?
          upsert_collection_price(collection)
          collection.reload
        end

        collection
      end
    end

    private

    def update_collection
      collection = Collection.find(id)
      collection.update!(collection_attributes)
      collection
    end

    def create_collection
      Collection.create!(collection_attributes)
    end

    def collection_attributes
      {
        title:,
        user_id:,
        status:,
        thumbnail:,
        description:,
        place_ids: place_ids.compact
      }.compact
    end

    def upsert_collection_price(collection)
      collection_price = collection.collection_price || collection.build_collection_price
      collection_price.assign_attributes(collection_price_attributes.to_attributes)
      collection_price.payment_info = collection.user.collection_purchase_payment_info
      collection_price.save!

      setup_stripe_price(collection_price)
    end

    def setup_stripe_price(collection_price)
      Collections::Prices::SyncToProviderJob.perform_later(
        collection_price_id: collection_price.id
      )
    end
  end
end
