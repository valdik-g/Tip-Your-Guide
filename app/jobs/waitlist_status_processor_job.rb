class WaitlistStatusProcessorJob < ApplicationJob
  queue_as :default

  def perform(waitlist_id)
    waitlist = Waitlist.find(waitlist_id)

    WaitlistStatusProcessor.new(waitlist).process
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "Failed to find waitlist #{waitlist_id}: #{e.message}"
  end
end
