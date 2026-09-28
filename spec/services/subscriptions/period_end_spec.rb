require "rails_helper"

RSpec.describe Subscriptions::PeriodEnd do
  def stripe_subscription(payload)
    Stripe::Util.convert_to_stripe_object({id: "sub_test", object: "subscription", **payload})
  end

  let(:period_end) { 1.month.from_now }

  it "returns nil when the subscription carries no period at all" do
    result = described_class.call(stripe_subscription({items: {object: "list", data: []}}))

    expect(result).to be_nil
  end

  it "does not raise when the subscription has no items" do
    result = described_class.call(stripe_subscription({}))

    expect(result).to be_nil
  end

  it "reads a top-level current_period_end from older API versions" do
    subscription = stripe_subscription({current_period_end: period_end.to_i})

    expect(described_class.call(subscription)).to be_within(1.second).of(period_end)
  end

  it "reads current_period_end from the subscription item" do
    subscription = stripe_subscription({
      items: {
        object: "list",
        data: [{id: "si_test", object: "subscription_item", current_period_end: period_end.to_i}]
      }
    })

    expect(described_class.call(subscription)).to be_within(1.second).of(period_end)
  end

  it "prefers the top-level value when both are present" do
    subscription = stripe_subscription({
      current_period_end: period_end.to_i,
      items: {
        object: "list",
        data: [{id: "si_test", object: "subscription_item", current_period_end: 2.months.from_now.to_i}]
      }
    })

    expect(described_class.call(subscription)).to be_within(1.second).of(period_end)
  end

  it "takes the latest item when the subscription has several items" do
    subscription = stripe_subscription({
      items: {
        object: "list",
        data: [
          {id: "si_1", object: "subscription_item", current_period_end: period_end.to_i},
          {id: "si_2", object: "subscription_item", current_period_end: 2.months.from_now.to_i}
        ]
      }
    })

    expect(described_class.call(subscription)).to be_within(1.second).of(2.months.from_now)
  end
end
