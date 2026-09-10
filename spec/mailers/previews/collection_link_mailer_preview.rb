# Preview all emails at http://localhost:3000/rails/mailers/collection_link_mailer

require "factory_bot_rails"

class CollectionLinkMailerPreview < ActionMailer::Preview
  def purchased
    user = User.first || FactoryBot.create(:user)
    collection = Collection.first || FactoryBot.create(:collection, user: user)
    collection_link = CollectionLink.first || FactoryBot.create(:collection_link, collection: collection, user: user)

    CollectionLinkMailer.purchased(
      collection_link: collection_link,
      customer_email: "customer@example.com"
    )
  end
end
