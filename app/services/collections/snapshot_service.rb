module Collections
  class SnapshotService
    def initialize(collection)
      @collection = collection
    end

    def call
      data = collection
      data["places"] = places
      data
    end

    private

    def places
      @collection.places.as_json(except: [:id, :created_at, :updated_at, :user_id])
    end

    def collection
      @collection.as_json(except: [:id, :created_at, :updated_at, :user_id])
    end
  end
end
