FactoryBot.define do
  factory :payment do
    amount { 1000 }
    currency { "usd" }
    sequence(:stripe_id) { |n| "stripe_cs_test_#{n}" }

    association :user
    association :payment_info

    trait :with_last_payment_status do
      after(:create) do |payment|
        create(:payment_status, payment:)
      end
    end
  end
end
