FactoryBot.define do
  factory :payment_status, class: Payment::Status do
    kind { "paid" }
    last { true }
    association :payment
  end
end
