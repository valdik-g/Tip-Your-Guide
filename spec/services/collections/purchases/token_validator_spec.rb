require "rails_helper"

RSpec.describe Collections::Purchases::TokenValidator do
  let(:collection) { create(:collection) }
  let(:token) { Collections::Purchases::TokenCreator.new(collection).call }

  subject(:validator) { described_class.new(token) }

  describe "#call" do
    it "successfully decodes a valid token" do
      result = validator.call
      expect(result).to be_a(Hash)
      expect(result["collection_id"]).to eq(collection.id)
      expect(result["timestamp"]).to be_present
      expect(result["exp"]).to be_present
    end

    context "when token is expired" do
      let(:expired_token) do
        payload = {
          collection_id: collection.id,
          timestamp: Time.current.to_i,
          exp: 1.hour.ago.to_i
        }
        JWT.encode(payload, Rails.application.secret_key_base, "HS256")
      end

      it "raises ExpiredTokenError" do
        validator = described_class.new(expired_token)
        expect { validator.call }.to raise_error(
          Collections::Purchases::TokenValidator::ExpiredTokenError,
          "Payment session expired"
        )
      end
    end

    context "when token is invalid" do
      let(:invalid_token) { "invalid.token.string" }

      it "raises InvalidTokenError" do
        validator = described_class.new(invalid_token)
        expect { validator.call }.to raise_error(
          Collections::Purchases::TokenValidator::InvalidTokenError,
          "Invalid payment token"
        )
      end
    end

    context "when token is signed with wrong key" do
      let(:wrong_key_token) do
        payload = {
          collection_id: collection.id,
          timestamp: Time.current.to_i,
          exp: 1.hour.from_now.to_i
        }
        JWT.encode(payload, "wrong_secret", "HS256")
      end

      it "raises InvalidTokenError" do
        validator = described_class.new(wrong_key_token)
        expect { validator.call }.to raise_error(
          Collections::Purchases::TokenValidator::InvalidTokenError,
          "Invalid payment token"
        )
      end
    end
  end
end
