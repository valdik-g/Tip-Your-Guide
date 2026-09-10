class TelegramNotificationJob < ApplicationJob
  queue_as :default

  def perform(object, type: :waitlist)
    if type == :waitlist
      waitlist = Waitlist.find(object)
      TelegramNotifier.new(waitlist).notify_new_waitlist
    elsif type == :payment
      TelegramNotifier.new(object).notify_new_payment
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "TelegramNotificationJob: Something happened with #{object}: #{e.message}"
  end
end
