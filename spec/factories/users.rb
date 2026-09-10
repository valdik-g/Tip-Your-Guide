FactoryBot.define do
  factory :user do
    email { "user#{rand(1000000)}@example.com" }
    password { "password" }
    password_confirmation { "password" }
    full_name { "John Doe" }
    country { "ES" }
    city { "Barcelona" }
    bio { "I'm a user" }

    trait :admin do
      after(:create) do |user|
        role = create(:role, :admin)

        user.add_role(role.name)
      end
    end

    trait :guide do
      after(:create) do |user|
        role = create(:role, :guide)

        user.add_role(role.name)
      end
    end

    trait :with_payment_info do
      after(:create) do |user|
        create(:payment_info, :donation_purchase, user: user)
      end
    end
  end
end
