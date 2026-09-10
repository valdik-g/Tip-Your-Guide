module Collections
  class PurchasesController < ApplicationController
    allow_unauthenticated_access

    def create
      collection = Collection.paid_status.find(params[:collection_id])
      checkout_session = Collections::Purchases::CheckoutSessionCreator.new(collection).call

      redirect_to checkout_session.url, allow_other_host: true
    end

    def success
      checkout_session_id = params[:session_id]
      purchase_result = Collections::Purchases::SuccessHandler.new(
        token: params[:token],
        session:,
        checkout_session_id:
      ).call

      redirect_to purchase_result.url
    end
  end
end
