FactoryBot.define do
  factory :waitlist do
    sequence(:email) { |n| "user#{n}@example.com" }
    full_name { "John Doe" }
    country { "United States" }
    city { "New York" }
    status { "pending" }

    trait :contacted do
      status { "contacted" }
    end

    trait :approved do
      status { "approved" }
    end

    trait :rejected do
      status { "rejected" }
    end

    trait :with_user do
      user
    end
  end
end
