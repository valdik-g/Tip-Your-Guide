class Waitlist < ApplicationRecord
  belongs_to :user, optional: true

  enum :status, {pending: 0, contacted: 1, approved: 2, rejected: 3}
  enum :reason, {
    local_guide: 0,
    local_expert: 1,
    traveler_sharer: 2,
    traveler_seeker: 3
  }

  validates :email, presence: true, uniqueness: true

  after_create :notify_telegram
  after_update_commit :process_status_change

  def user_location
    [city, ISO3166::Country[country]&.iso_long_name].compact.join(", ")
  end

  private

  def notify_telegram
    return unless Rails.env.production?

    TelegramNotificationJob.perform_later(id, type: :waitlist)
  end

  def process_status_change
    return unless saved_change_to_status?

    WaitlistStatusProcessorJob.perform_later(id)
  end
end
