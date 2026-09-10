module Collections
  module Purchases
    class TokenValidator
      class ExpiredTokenError < StandardError; end

      class InvalidTokenError < StandardError; end

      def initialize(token)
        @token = token
      end

      def call
        decode_token
      end

      private

      attr_reader :token

      def decode_token
        JWT.decode(
          token,
          secret_key,
          true,
          algorithm: "HS256"
        ).first
      rescue JWT::ExpiredSignature
        raise ExpiredTokenError, "Payment session expired"
      rescue JWT::DecodeError
        raise InvalidTokenError, "Invalid payment token"
      end

      def secret_key
        Rails.application.secret_key_base
      end
    end
  end
end
