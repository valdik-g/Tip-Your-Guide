require "rails_helper"

RSpec.describe "Blog posts premium content", type: :request do
  let(:user) { create(:user) }
  let(:blog_post) { create(:blog_post, :with_premium) }

  def read_post
    get blog_post_path(locale: blog_post.locale, slug: blog_post.slug)
  end

  describe "GET /blog/:locale/:slug" do
    context "when the post has no premium part" do
      let(:blog_post) { create(:blog_post) }

      it "renders the post" do
        read_post

        expect(response).to have_http_status(:ok)
      end
    end

    context "when the signed-in visitor has no subscription" do
      before { sign_in_as user }

      it "teases the premium part and offers a subscription" do
        read_post

        expect(response.body).to include(I18n.t("subscription.teaser.headline"))
        expect(response.body).to include(I18n.t("subscription.subscribe"))
        expect(response.body).not_to include("Premium Content")
      end
    end

    context "when the subscription is active" do
      let!(:subscription) { create(:subscription, user: user) }

      before { sign_in_as user }

      it "renders the premium part without a teaser" do
        read_post

        expect(response.body).to include("Premium Content")
        expect(response.body).not_to include(I18n.t("subscription.teaser.headline"))
      end
    end

    context "when the payment failed but the grace period has not run out" do
      let!(:subscription) { create(:subscription, :past_due, user: user) }

      before { sign_in_as user }

      it "renders the premium part and offers no way to renew" do
        read_post

        expect(response.body).to include("Premium Content")
        expect(response.body).not_to include(I18n.t("subscription.teaser.headline"))
        expect(response.body).not_to include(I18n.t("subscription.renew"))
      end
    end

    context "when the grace period has run out" do
      let!(:subscription) { create(:subscription, :past_due_expired, user: user) }

      before { sign_in_as user }

      it "teases the premium part and offers a renewal" do
        read_post

        expect(response.body).to include(I18n.t("subscription.teaser.headline"))
        expect(response.body).to include(I18n.t("subscription.renew"))
        expect(response.body).not_to include(I18n.t("subscription.subscribe"))
      end
    end

    context "when the subscription is canceled" do
      let!(:subscription) { create(:subscription, :canceled_expired, user: user) }

      before { sign_in_as user }

      it "teases the premium part and offers a renewal" do
        read_post

        expect(response.body).to include(I18n.t("subscription.teaser.headline"))
        expect(response.body).to include(I18n.t("subscription.renew"))
      end
    end

    context "when the visitor is not signed in" do
      it "sends them to the login page instead of checkout" do
        read_post

        expect(response.body).to include(I18n.t("subscription.teaser.headline"))
        expect(response.body).to include(I18n.t("subscription.teaser.login_to_subscribe"))
        expect(response.body).not_to include(I18n.t("subscription.subscribe"))
      end
    end
  end
end
