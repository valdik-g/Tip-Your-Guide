FactoryBot.define do
  factory :subscription do
    user
    stripe_subscription_id { "sub_#{SecureRandom.alphanumeric(14)}" }
    stripe_customer_id { "cus_#{SecureRandom.alphanumeric(14)}" }
    status { 'active' }
    current_period_end { 1.month.from_now }
    cancel_at_period_end { false }

    trait :past_due do
      status { 'past_due' }
      current_period_end { 3.days.ago }
    end

    trait :past_due_expired do
      status { 'past_due' }
      current_period_end { 10.days.ago }
    end

    trait :canceled do
      status { 'active' }
      cancel_at_period_end { true }
      current_period_end { 1.week.from_now }
    end

    trait :canceled_expired do
      status { 'canceled' }
      current_period_end { 1.day.ago }
    end

    trait :incomplete do
      status { 'incomplete' }
    end
  end
end