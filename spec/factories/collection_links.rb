FactoryBot.define do
  factory :collection_link do
    user
    collection

    link { SecureRandom.alphanumeric(4) }
  end
end
