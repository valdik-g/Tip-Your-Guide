FactoryBot.define do
  factory :role do
    name { "user" }
    resource_type { nil }
    resource_id { nil }

    trait :admin do
      to_create do |instance|
        instance.id = Role.find_or_create_by(name: "admin").id
        instance.reload
      end
    end

    trait :guide do
      to_create do |instance|
        instance.id = Role.find_or_create_by(name: "guide").id
        instance.reload
      end
    end
  end
end
