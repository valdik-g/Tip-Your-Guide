FactoryBot.define do
  factory :place do
    association :user
    title { "Test Place" }
    description { "This is a test place" }
    url { "https://www.example.com" }
  end
end
