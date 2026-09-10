require "rails_helper"

RSpec.describe Collections::Purchases::SuccessHandler do
  let(:collection) { create(:collection) }
  let(:token) { Collections::Purchases::TokenCreator.new(collection).call }
  let(:session) { {} }
  let(:checkout_session_id) { "cs_test_123" }

  let(:service) { described_class.new(token:, session:, checkout_session_id:) }

  describe "#call" do
    let(:collection_link) { instance_double(CollectionLink, link: "abc123", id: 1) }
    let(:redirect_url) { "http://example.com/abc123" }

    before do
      allow(Collection).to receive(:find).with(collection.id).and_return(collection)
      allow(CollectionLink).to receive(:create!).and_return(collection_link)
      allow(Rails.application.routes.url_helpers).to receive(:short_collection_link_url).with("abc123").and_return(redirect_url)
      allow(PosthogClient).to receive(:capture)
    end

    context "when everything succeeds" do
      let(:decoded_payload) { {"collection_id" => collection.id} }

      before do
        allow(Collections::Purchases::TokenValidator).to receive_message_chain(:new, :call)
          .and_return(decoded_payload)
      end

      it "finds the collection" do
        expect(Collection).to receive(:find).with(collection.id)
        service.call
      end

      it "creates a collection link with correct attributes" do
        expect(CollectionLink).to receive(:create!).with(
          collection: collection,
          status: :paid,
          user: collection.user
        )
        service.call
      end

      it "returns an OpenStruct with the redirect URL" do
        result = service.call
        expect(result).to be_a(OpenStruct)
        expect(result.url).to eq(redirect_url)
      end

      it "schedules the PurchaseEmailJob with correct arguments" do
        expect(CollectionLinks::PurchaseEmailJob).to receive(:perform_later).with(
          collection_link_id: collection_link.id,
          stripe_checkout_session_id: checkout_session_id
        )
        service.call
      end
    end

    context "when token is invalid" do
      let(:token) { "invalid.token.string" }
      let(:error_message) { "Invalid payment token" }

      before do
        allow(Collections::Purchases::TokenValidator).to receive_message_chain(:new, :call)
          .and_raise(Collections::Purchases::TokenValidator::InvalidTokenError.new(error_message))
      end

      it "returns an OpenStruct with root URL and error message" do
        result = service.call
        expect(result).to be_a(OpenStruct)
        expect(result.url).to eq(root_url)
        expect(result.message).to eq(error_message)
      end

      it "captures the error in Posthog" do
        service.call
        expect(PosthogClient).to have_received(:capture).with(
          distinct_id: "system",
          event: "payment_error",
          properties: {error: error_message, token: token}
        )
      end
    end

    context "when token is expired" do
      let(:token) { "expired.token.string" }
      let(:error_message) { "Payment session expired" }

      before do
        allow(Collections::Purchases::TokenValidator).to receive_message_chain(:new, :call)
          .and_raise(Collections::Purchases::TokenValidator::ExpiredTokenError.new(error_message))
      end

      it "returns an OpenStruct with root URL and error message" do
        result = service.call
        expect(result).to be_a(OpenStruct)
        expect(result.url).to eq(root_url)
        expect(result.message).to eq(error_message)
      end

      it "captures the error in Posthog" do
        service.call
        expect(PosthogClient).to have_received(:capture).with(
          distinct_id: "system",
          event: "payment_error",
          properties: {error: error_message, token: token}
        )
      end
    end

    context "when collection is not found" do
      let(:error_message) { "Couldn't find Collection with id=#{collection.id}" }

      before do
        allow(Collection).to receive(:find).with(collection.id)
          .and_raise(ActiveRecord::RecordNotFound.new(error_message))
      end

      it "returns an OpenStruct with root URL and error message" do
        result = service.call
        expect(result).to be_a(OpenStruct)
        expect(result.url).to eq(root_url)
        expect(result.message).to eq(error_message)
      end

      it "captures the error in Posthog" do
        service.call
        expect(PosthogClient).to have_received(:capture).with(
          distinct_id: "system",
          event: "payment_error",
          properties: {error: error_message, token: token}
        )
      end
    end

    context "when collection link creation fails" do
      let(:error_message) { "Validation failed: Some validation error" }
      let(:collection_link) { build(:collection_link) }

      before do
        collection_link.errors.add(:base, "Some validation error")

        allow(CollectionLink).to receive(:create!)
          .and_raise(ActiveRecord::RecordInvalid.new(collection_link))
      end

      it "returns an OpenStruct with root URL and error message" do
        result = service.call
        expect(result).to be_a(OpenStruct)
        expect(result.url).to eq(root_url)
        expect(result.message).to eq(error_message)
      end

      it "captures the error in Posthog" do
        service.call
        expect(PosthogClient).to have_received(:capture).with(
          distinct_id: "system",
          event: "payment_error",
          properties: {error: error_message, token: token}
        )
      end
    end
  end

  private

  def root_url
    Rails.application.routes.url_helpers.root_url
  end
end
