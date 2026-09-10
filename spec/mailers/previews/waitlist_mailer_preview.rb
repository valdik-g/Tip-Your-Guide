# Preview all emails at http://localhost:3000/rails/mailers/waitlist_mailer

require "factory_bot_rails"

class WaitlistMailerPreview < ActionMailer::Preview
  def approved
    waitlist = Waitlist.first || FactoryBot.create(:waitlist)
    token = "preview_reset_token_123"

    WaitlistMailer.approved(waitlist, token)
  end

  def rejected
    waitlist = Waitlist.first || FactoryBot.create(:waitlist)

    WaitlistMailer.rejected(waitlist)
  end
end
