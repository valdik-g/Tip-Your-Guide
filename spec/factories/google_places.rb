FactoryBot.define do
  factory :google_place do
    association :place
    external_id { "ChIJ2aPIrX-EhYARCnGUgT7g0vU" }
    metadata { {} }
  end
end
