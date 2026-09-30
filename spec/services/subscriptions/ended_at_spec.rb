require "rails_helper"

RSpec.describe Subscriptions::EndedAt do
  def stripe_subscription(payload)
    Stripe::Util.convert_to_stripe_object({id: "sub_test", object: "subscription", **payload})
  end

  let(:ended_at) { 1.week.ago }

  it "returns nil when the subscription carries no end" do
    expect(described_class.call(stripe_subscription({}))).to be_nil
  end

  it "reads ended_at" do
    subscription = stripe_subscription({ended_at: ended_at.to_i})

    expect(described_class.call(subscription)).to be_within(1.second).of(ended_at)
  end

  it "falls back to canceled_at on API versions without ended_at" do
    subscription = stripe_subscription({canceled_at: ended_at.to_i})

    expect(described_class.call(subscription)).to be_within(1.second).of(ended_at)
  end

  it "prefers ended_at over canceled_at" do
    subscription = stripe_subscription({
      ended_at: ended_at.to_i,
      canceled_at: 1.month.ago.to_i
    })

    expect(described_class.call(subscription)).to be_within(1.second).of(ended_at)
  end
end
