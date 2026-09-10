# frozen_string_literal: true

namespace :one_time do
  task reset_places_count: :environment do
    Collection.all.find_each do |collection|
      Collection.reset_counters(collection.id, :collection_places)
    end
  end
end
