class CollectionPlace < ApplicationRecord
  belongs_to :collection, counter_cache: :places_count
  belongs_to :place
end
