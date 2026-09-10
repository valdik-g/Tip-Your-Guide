FactoryBot.define do
  factory :collection do
    title { "Sample Collection" }
    description { "Sample Collection Description" }
    user

    trait :with_places do
      after(:create) do |collection|
        places = create_list(:place, 3)
        collection.places << places
      end
    end

    trait :with_collection_link do
      after(:create) do |collection|
        create(:collection_link, collection: collection)
      end
    end
  end
end
