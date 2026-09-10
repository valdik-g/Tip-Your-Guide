module Collections
  module Purchases
    class TokenCreator
      def initialize(collection)
        @collection = collection
      end

      def call
        encode_token
      end

      private

      attr_reader :collection

      def encode_token
        JWT.encode(payload, secret_key, "HS256")
      end

      def payload
        {
          collection_id: collection.id,
          timestamp: Time.current.to_i,
          exp: 1.hour.from_now.to_i
        }
      end

      def secret_key
        Rails.application.secret_key_base
      end
    end
  end
end
