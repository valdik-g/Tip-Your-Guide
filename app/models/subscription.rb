class Subscription < ApplicationRecord
  belongs_to :user

  validates :stripe_subscription_id, presence: true, uniqueness: true
  validates :user_id, uniqueness: true

  enum :status, {
    active: 'active',
    past_due: 'past_due',
    canceled: 'canceled',
    incomplete: 'incomplete'
  }

  GRACE_PERIOD_DAYS = 7
  
  def accessible?
    case status
    when 'active'
      true
    when 'past_due'
      current_period_end.present? && current_period_end > GRACE_PERIOD_DAYS.days.ago
    else
      false
    end
  end

  def days_until_access_loss
    return nil unless past_due? && current_period_end.present?

    deadline = current_period_end + GRACE_PERIOD_DAYS.days
    remaining = ((deadline - Time.current) / 1.day).ceil
    [remaining, 0].max
  end

  def will_cancel?
    cancel_at_period_end? && active?
  end

  def renewable?
    !accessible?
  end

  def ends_at
    will_cancel? ? current_period_end : nil
  end
end