require "rails_helper"

RSpec.describe SubscriptionTeaser::TeaserComponent, type: :component do
  let(:user) { create(:user) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  def render_teaser(subscription: nil)
    render_inline(described_class.new(title: "Premium", subscription: subscription))
  end

  context "when the visitor has no subscription" do
    it "offers a subscription" do
      expect(render_teaser).to have_button(I18n.t("subscription.subscribe"))
    end
  end

  context "when the cancelled subscription is past its period" do
    let(:subscription) { create(:subscription, :canceled_expired, user: user) }

    it "offers a renewal instead" do
      rendered = render_teaser(subscription: subscription)

      expect(rendered).to have_button(I18n.t("subscription.renew"))
      expect(rendered).not_to have_button(I18n.t("subscription.subscribe"))
    end
  end

  context "when the grace period has run out" do
    let(:subscription) { create(:subscription, :past_due_expired, user: user) }

    it "offers a renewal" do
      expect(render_teaser(subscription: subscription)).to have_button(
        I18n.t("subscription.renew")
      )
    end
  end
end
