require "rails_helper"

RSpec.describe Collections::UpsertService, type: :service do
  describe "#call" do
    let(:user) { create(:user) }
    let(:place) { create(:place, user:) }
    let(:collection_price_attributes) { {price: 100, currency: "usd"} }
    let(:thumbnail) { fixture_file_upload(Rails.root.join("spec/fixtures/files/sample-image.png"), "image/png") }
    let(:params) { nil }
    let(:service) do
      described_class.new(**params)
    end

    context "when creating a new collection" do
      let(:params) do
        {
          title: "New Collection",
          description: "A description",
          user_id: user.id,
          status: "public",
          place_ids: [place.id],
          collection_price_attributes: collection_price_attributes,
          thumbnail: thumbnail
        }
      end

      it "creates a new collection with the correct attributes" do
        collection = service.call

        expect(collection).to be_persisted
        expect(collection.title).to eq("New Collection")
        expect(collection.description.to_plain_text).to eq("A description")
        expect(collection.user_id).to eq(user.id)
        expect(collection.status).to eq("public")
        expect(collection.places).to include(place)
        expect(collection.thumbnail).to be_attached
      end

      context "when creating paid collection" do
        let!(:payment_info) do
          create(:payment_info, :collection_purchase, user:)
        end

        it "creates a collection price if the status is paid" do
          params[:status] = "paid"
          collection = service.call

          expect(collection.collection_price).to be_present
          expect(collection.collection_price.price).to eq(100)
          expect(collection.collection_price.currency).to eq("usd")
        end

        context "when payment info not set" do
          let!(:payment_info) { nil }

          it "raises an error" do
            params[:status] = "paid"
            expect { service.call }.to raise_error(ActiveRecord::RecordInvalid, /Payment info must exist/)
          end
        end
      end
    end

    context "when updating an existing collection" do
      let(:existing_collection) { create(:collection, user: user, status: "draft") }
      let(:params) do
        {
          id: existing_collection.id,
          title: "Updated Collection",
          description: "Updated description",
          user_id: user.id,
          status: "public",
          place_ids: [place.id],
          collection_price_attributes: collection_price_attributes,
          thumbnail: thumbnail
        }
      end

      it "updates the collection with the correct attributes" do
        collection = service.call

        expect(collection.title).to eq("Updated Collection")
        expect(collection.description.to_plain_text).to eq("Updated description")
        expect(collection.status).to eq("public")
        expect(collection.places).to include(place)
        expect(collection.thumbnail).to be_attached
      end

      context "when updating paid collection" do
        let!(:payment_info) do
          create(:payment_info, :collection_purchase, user:)
        end

        it "updates the collection price if the status is paid" do
          params[:status] = "paid"
          collection = service.call

          expect(collection.collection_price).to be_present
          expect(collection.collection_price.price).to eq(100)
          expect(collection.collection_price.currency).to eq("usd")
        end
      end
    end
  end
end
