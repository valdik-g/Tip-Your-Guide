FactoryBot.define do
  factory :payment_info do
    association :user
    sequence(:stripe_product_id) { |n| "stripe_prod_#{n}" }
    charge_type { :donation_purchase }

    trait :collection_purchase do
      charge_type { :collection_purchase }
    end

    trait :donation_purchase do
      charge_type { :donation_purchase }
    end
  end
end
