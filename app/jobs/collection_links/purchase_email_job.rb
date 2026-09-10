module CollectionLinks
  class PurchaseEmailJob < ApplicationJob
    def perform(collection_link_id:, stripe_checkout_session_id:)
      collection_link = CollectionLink.find(collection_link_id)
      stripe_checkout_session = Stripe::Checkout::Session.retrieve(stripe_checkout_session_id)
      customer_email = stripe_checkout_session.customer_details.email
      return if customer_email.blank?

      send_purchase_email(collection_link:, customer_email:)
    end

    private

    def send_purchase_email(collection_link:, customer_email:)
      CollectionLinkMailer.purchased(
        collection_link:,
        customer_email:
      ).deliver_now
    end
  end
end
