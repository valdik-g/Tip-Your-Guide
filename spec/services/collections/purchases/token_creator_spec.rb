require "rails_helper"

RSpec.describe Collections::Purchases::TokenCreator do
  let(:collection) { create(:collection) }

  subject(:creator) { described_class.new(collection) }

  describe "#call" do
    let(:token) { creator.call }

    it "generates a valid JWT token" do
      expect(token).to be_a(String)
      expect(token.split(".").length).to eq(3) # JWT has three parts
    end

    it "includes collection_id in the payload" do
      decoded_token = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: "HS256")
      expect(decoded_token.first["collection_id"]).to eq(collection.id)
    end

    it "includes timestamp in the payload" do
      decoded_token = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: "HS256")
      expect(decoded_token.first["timestamp"]).to be_present
    end

    it "sets expiration to 1 hour from now" do
      decoded_token = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: "HS256")
      exp = decoded_token.first["exp"]
      expect(exp).to be_within(1).of(1.hour.from_now.to_i)
    end

    it "uses the correct secret key" do
      expect { JWT.decode(token, "wrong_secret", true, algorithm: "HS256") }
        .to raise_error(JWT::VerificationError)
    end
  end
end
