require "rails_helper"

RSpec.describe "Blog post premium content is withheld", type: :request do
  let(:blog_post) { create(:blog_post, :with_premium) }
  let(:user) { create(:user) }

  let(:premium_body) { blog_post.blog_post_premium.premium_content }
  let(:premium_title) { blog_post.blog_post_premium.premium_title }

  def read_post
    get blog_post_path(locale: blog_post.locale, slug: blog_post.slug)
  end

  shared_examples "a reader without access" do
    it "does not put the premium body in the response" do
      read_post

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include(premium_body)
    end

    it "shows the teaser instead of the premium body" do
      read_post

      expect(response.body).to include("filter: blur(4px)")
      expect(response.body).to include(I18n.t("subscription.teaser.price"))
    end

    it "labels the teaser with the premium title without opening the body" do
      read_post

      expect(response.body).to include(premium_title)
      expect(response.body).not_to include(premium_body)
    end
  end

  context "when the visitor is not signed in" do
    include_examples "a reader without access"
  end

  context "when the signed-in visitor has no subscription" do
    before { sign_in_as user }

    include_examples "a reader without access"
  end

  context "when the grace period has run out" do
    let!(:subscription) { create(:subscription, :past_due_expired, user: user) }

    before { sign_in_as user }

    include_examples "a reader without access"
  end

  context "when the subscription is canceled and the period is over" do
    let!(:subscription) { create(:subscription, :canceled_expired, user: user) }

    before { sign_in_as user }

    include_examples "a reader without access"
  end

  context "when the payment never completed" do
    let!(:subscription) { create(:subscription, :incomplete, user: user) }

    before { sign_in_as user }

    include_examples "a reader without access"
  end
end
