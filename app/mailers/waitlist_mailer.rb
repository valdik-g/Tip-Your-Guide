class WaitlistMailer < ApplicationMailer
  def approved(waitlist, token)
    @waitlist = waitlist
    @token = token
    mail subject: I18n.t("mailers.waitlist_mailer.approved.subject"), to: waitlist.email
  end

  def rejected(waitlist)
    @waitlist = waitlist
    mail subject: I18n.t("mailers.waitlist_mailer.rejected.subject"), to: waitlist.email
  end
end
