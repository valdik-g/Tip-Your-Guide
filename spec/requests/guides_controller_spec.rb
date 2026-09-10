require "rails_helper"

RSpec.describe GuidesController, type: :request do
  describe "GET /guides/:id" do
    let(:guide) { create(:user, :guide, full_name: "Anna Castro") }

    context "with published collections" do
      let!(:public_collection) do
        create(:collection, user: guide, title: "Sunday Mornings", status: :public)
      end
      let!(:draft_collection) do
        create(:collection, user: guide, title: "Not Ready Yet", status: :draft)
      end

      it "renders the profile" do
        get guide_path(guide.slug)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Anna Castro")
      end

      it "lists published collections" do
        get guide_path(guide.slug)

        expect(response.body).to include("Sunday Mornings")
      end

      it "does not list draft collections" do
        get guide_path(guide.slug)

        expect(response.body).not_to include("Not Ready Yet")
      end
    end

    context "with no collections" do
      it "still renders the profile" do
        get guide_path(guide.slug)

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
