module Collections
  module Purchases
    # Handles successful collection purchases by creating a paid collection link
    # and returning the appropriate redirect URL.
    #
    # @param token [String] JWT token containing collection_id
    # @return [OpenStruct] Contains url and optional message
    class SuccessHandler
      def initialize(token:, session:, checkout_session_id:)
        @token = token
        @session = session
        @checkout_session_id = checkout_session_id
      end

      def call
        collection = find_collection
        collection_link = create_collection_link(collection)
        url = redirect_url(collection_link)
        update_session(collection_link)
        enqueue_email_job(collection_link)

        result(url)
      rescue Collections::Purchases::TokenValidator::InvalidTokenError,
        Collections::Purchases::TokenValidator::ExpiredTokenError => e
        handle_error(e.message)
      rescue ActiveRecord::RecordNotFound,
        ActiveRecord::RecordInvalid => e
        handle_error(e.message)
      end

      private

      attr_reader :token, :checkout_session_id

      def find_collection
        Collection.find(collection_id)
      end

      def create_collection_link(collection)
        CollectionLink.create!(
          collection: collection,
          status: :paid,
          user: collection.user
        )
      end

      def update_session(collection_link)
        @session[:purchased] ||= []
        @session[:purchased] << collection_link.link
      end

      def enqueue_email_job(collection_link)
        CollectionLinks::PurchaseEmailJob.perform_later(
          collection_link_id: collection_link.id,
          stripe_checkout_session_id: checkout_session_id
        )
      end

      def collection_id
        decoded_payload["collection_id"]
      end

      def decoded_payload
        @decoded_payload ||= Collections::Purchases::TokenValidator.new(token).call
      end

      def redirect_url(collection_link)
        Rails.application.routes.url_helpers.short_collection_link_url(collection_link.link)
      end

      def root_url
        Rails.application.routes.url_helpers.root_url
      end

      def handle_error(error)
        PosthogClient.capture(
          distinct_id: "system",
          event: "payment_error",
          properties: {error:, token:}
        )

        OpenStruct.new(url: root_url, message: error)
      end

      def result(url)
        OpenStruct.new(url: url)
      end
    end
  end
end
