FactoryBot.define do
  factory :collection_price, class: "Collection::Price" do
    price { 100 }
    currency { 0 }
    sequence(:stripe_id) { |n| "stripe_price_#{n}" }
  end
end
