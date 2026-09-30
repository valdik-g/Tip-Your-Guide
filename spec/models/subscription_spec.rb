require 'rails_helper'

RSpec.describe Subscription, type: :model do
  describe '#accessible?' do
    context 'when status is active' do
      it 'returns true' do
        subscription = build(:subscription)
        expect(subscription.accessible?).to be true
      end
    end

    context 'when status is past_due within grace period' do
      it 'returns true' do
        subscription = build(:subscription, :past_due)
        expect(subscription.accessible?).to be true
      end
    end

    context 'when status is past_due outside grace period' do
      it 'returns false' do
        subscription = build(:subscription, :past_due_expired)
        expect(subscription.accessible?).to be false
      end
    end

    context 'when status is canceled' do
      it 'returns false' do
        subscription = build(:subscription, :canceled_expired)
        expect(subscription.accessible?).to be false
      end
    end

    context 'when status is incomplete' do
      it 'returns false' do
        subscription = build(:subscription, :incomplete)
        expect(subscription.accessible?).to be false
      end
    end
  end

  describe '#will_cancel?' do
    it 'returns true when active and cancel_at_period_end is true' do
      subscription = build(:subscription, :canceled)
      expect(subscription.will_cancel?).to be true
    end

    it 'returns false when active but not canceled' do
      subscription = build(:subscription)
      expect(subscription.will_cancel?).to be false
    end

    it 'returns false when canceled but not accessible' do
      subscription = build(:subscription, :canceled_expired)
      expect(subscription.will_cancel?).to be false
    end
  end

  describe '#ends_at' do
    it 'returns current_period_end when will_cancel? is true' do
      subscription = build(:subscription, :canceled)
      expect(subscription.ends_at).to eq(subscription.current_period_end)
    end

    it 'returns nil when will_cancel? is false' do
      subscription = build(:subscription)
      expect(subscription.ends_at).to be_nil
    end
  end

  describe "#ended_on" do
    it "returns the period end for a canceled subscription that already ended" do
      subscription = build(:subscription, :canceled_expired)
      expect(subscription.ended_on).to eq(subscription.current_period_end)
    end

    it "returns nil when a canceled subscription carries a period end in the future" do
      subscription = build(:subscription, :canceled_with_time_left)
      expect(subscription.ended_on).to be_nil
    end

    it "returns nil when a canceled subscription has no period end at all" do
      subscription = build(:subscription, :canceled_expired, current_period_end: nil)
      expect(subscription.ended_on).to be_nil
    end

    it "returns the period end for a past_due subscription inside the grace period" do
      subscription = build(:subscription, :past_due)
      expect(subscription.ended_on).to eq(subscription.current_period_end)
    end

    it "returns the next renewal for an active subscription" do
      subscription = build(:subscription)
      expect(subscription.ended_on).to eq(subscription.current_period_end)
    end
  end

  describe '#renewable?' do
    it 'returns false while the subscription is active' do
      subscription = build(:subscription)
      expect(subscription.renewable?).to be false
    end

    it 'returns false while a cancelled subscription is still billed' do
      subscription = build(:subscription, :canceled)
      expect(subscription.renewable?).to be false
    end

    it 'returns false while a past_due subscription is inside the grace period' do
      subscription = build(:subscription, :past_due)
      expect(subscription.renewable?).to be false
    end

    it 'returns true once the grace period has run out' do
      subscription = build(:subscription, :past_due_expired)
      expect(subscription.renewable?).to be true
    end

    it 'returns true once the subscription is canceled' do
      subscription = build(:subscription, :canceled_expired)
      expect(subscription.renewable?).to be true
    end

    it 'returns true when the payment never completed' do
      subscription = build(:subscription, :incomplete)
      expect(subscription.renewable?).to be true
    end
  end

  describe '#days_until_access_loss' do
    it 'returns nil when not past_due' do
      subscription = build(:subscription)
      expect(subscription.days_until_access_loss).to be_nil
    end

    it 'returns days remaining when past_due' do
      subscription = build(:subscription, :past_due)
      expect(subscription.days_until_access_loss).to be > 0
    end

    it 'returns 0 when grace period expired' do
      subscription = build(:subscription, :past_due_expired)
      expect(subscription.days_until_access_loss).to eq(0)
    end
  end
end