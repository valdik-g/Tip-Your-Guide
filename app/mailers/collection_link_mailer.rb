class CollectionLinkMailer < ApplicationMailer
  def purchased(collection_link:, customer_email:)
    @collection_link = collection_link
    @customer_email = customer_email

    mail(
      subject: I18n.t("mailers.collection_link_mailer.purchased.subject", guide_name: collection_link.collection.user.full_name),
      to: customer_email
    )
  end
end
