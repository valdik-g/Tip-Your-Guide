require "rails_helper"

RSpec.describe Collections::CardComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:view_context) do
    controller = ActionController::Base.new
    allow(controller).to receive(:current_user).and_return(current_user)
    allow(controller).to receive(:session).and_return(session_data.with_indifferent_access)
    controller.view_context
  end

  # Helper to build a component with the required stubs
  # def build_component(collection:, paid_link:, current_user:, session_data: {})
  #   described_class.new(collection: collection, paid_link: paid_link).tap do |component|
  #     # Stub out controller helpers that component relies on
  #     allow(component).to receive(:current_user).and_return(current_user)
  #     allow(component).to receive(:session).and_return(session_data.with_indifferent_access)
  #   end
  # end

  def render_component(collection:, paid_link:, current_user:, session_data: {})
    @current_user = current_user
    @session_data = session_data
    render_inline(described_class.new(collection: collection, paid_link: paid_link))
  end

  describe "#requires_payment? / #collection_link_url" do
    let(:owner) { create(:user) }
    let(:admin) { create(:user, :admin) }
    let(:random_user) { create(:user) }

    context "when collection is public" do
      let(:collection) { create(:collection, user: owner, status: :public) }
      let(:paid_link) { nil }

      xit "does NOT require payment and returns public link" do
        rendered = render_component(collection: collection, paid_link: paid_link, current_user: random_user)

        expect(rendered).not_to have_link(href: checkout_collections_purchases_path(collection_id: collection.id))
      end
    end

    context "when collection is paid" do
      let!(:collection) { create(:collection, user: owner, status: :paid) }
      let!(:paid_link) { collection.paid_collection_links.first }

      context "and user is an admin" do
        xit "skips payment and returns paid link url" do
          component = render_component(collection: collection, paid_link: paid_link, current_user: admin)

          expect(component.show_paid_link_for_free?).to be_truthy
          expect(component.requires_payment?).to be_falsey
          expect(component.collection_link_url).to eq(paid_link.collection_link_url)
        end
      end

      context "and user is the owner" do
        xit "skips payment and returns paid link url" do
          component = build_component(collection: collection, paid_link: paid_link, current_user: owner)

          expect(component.show_paid_link_for_free?).to be_truthy
          expect(component.requires_payment?).to be_falsey
          expect(component.collection_link_url).to eq(paid_link.collection_link_url)
        end
      end

      context "and user already purchased the collection" do
        xit "recognises purchase via session and returns paid link url" do
          session_data = {purchased: [paid_link.id]}
          component = build_component(collection: collection, paid_link: paid_link, current_user: random_user, session_data: session_data)

          expect(component.requires_payment?).to be_falsey
          expect(component.user_paid_for_collection?).to be_truthy
          expect(component.collection_link_url).to eq(paid_link.collection_link_url)
        end
      end

      context "and user has NOT purchased the collection" do
        xit "requires payment and points to checkout url" do
          component = build_component(collection: collection, paid_link: paid_link, current_user: random_user)

          expect(component.requires_payment?).to be_truthy
          expected_checkout_path = checkout_collections_purchases_path(collection_id: collection.id)
          expect(component.collection_link_url).to eq(expected_checkout_path)
        end
      end
    end
  end

  describe "#user_paid_for_collection?" do
    let!(:collection) { create(:collection, status: :paid) }
    let!(:paid_link) { collection.paid_collection_links.first }

    xit "returns false for public collections" do
      public_collection = create(:collection, status: :public)
      component = build_component(collection: public_collection, paid_link: nil, current_user: nil)

      expect(component.user_paid_for_collection?).to be_falsey
    end

    xit "returns true when paid link itself is marked as paid" do
      paid_link.paid_status!
      component = build_component(collection: collection, paid_link: paid_link, current_user: nil)

      expect(component.user_paid_for_collection?).to be_truthy
    end

    xit "returns true when session includes the paid link id" do
      session_data = {purchased: [paid_link.id]}
      component = build_component(collection: collection, paid_link: paid_link, current_user: nil, session_data: session_data)

      expect(component.user_paid_for_collection?).to be_truthy
    end
  end
end
