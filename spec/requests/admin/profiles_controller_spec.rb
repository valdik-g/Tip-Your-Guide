require "rails_helper"

RSpec.describe "Admin profile subscription management", type: :request do
  let(:user) { create(:user) }

  before { sign_in_as user }

  def visit_profile
    get edit_admin_profile_url
  end

  describe "GET /admin/profile/edit" do
    context "when the user has no subscription" do
      it "offers a subscription" do
        visit_profile

        expect(response.body).to include(I18n.t("subscription.subscribe"))
        expect(response.body).not_to include(I18n.t("subscription.renew"))
      end
    end

    context "when the subscription is fully canceled" do
      let!(:subscription) { create(:subscription, :canceled_expired, user: user) }

      it "offers a renewal" do
        visit_profile

        expect(response.body).to include(I18n.t("subscription.renew"))
      end

      it "reports when the subscription ended" do
        visit_profile

        expect(response.body).to include(
          I18n.t(
            "subscription.ended_at",
            date: I18n.l(subscription.current_period_end, format: :long)
          )
        )
      end
    end

    context "when the cancelled subscription is still active until the period ends" do
      let!(:subscription) { create(:subscription, :canceled, user: user) }

      it "does not offer a renewal" do
        visit_profile

        expect(response.body).to include(
          I18n.t("subscription.will_cancel_at", date: I18n.l(subscription.ends_at, format: :long))
        )
        expect(response.body).not_to include(I18n.t("subscription.renew"))
      end
    end

    context "when a canceled subscription still carries a period end in the future" do
      let!(:subscription) { create(:subscription, :canceled_with_time_left, user: user) }

      it "does not claim the subscription ends on a future date" do
        visit_profile

        expect(response.body).not_to include(
          I18n.t(
            "subscription.ended_at",
            date: I18n.l(subscription.current_period_end, format: :long)
          )
        )
      end
    end

    context "when the subscription is active" do
      let!(:subscription) { create(:subscription, :active, user: user) }

      it "offers a cancellation instead of a renewal" do
        visit_profile

        expect(response.body).to include(I18n.t("subscription.cancel"))
        expect(response.body).not_to include(I18n.t("subscription.renew"))
      end

      it "submits the cancellation so the profile page reloads" do
        visit_profile

        cancel_form = response.body[
          %r{<form[^>]*action="#{Regexp.escape(subscription_path)}"[^>]*>.*?</form>}m
        ]

        expect(cancel_form).to include('data-turbo="false"')
        expect(cancel_form).to include('name="_method" value="delete"')
      end

      it "asks for a confirmation in a way that survives the reload" do
        visit_profile

        expect(response.body).to include(
          %(onclick="return confirm(&quot;#{I18n.t("subscription.cancel_confirmation")}&quot;)")
        )
      end
    end

    context "when a past_due subscription is inside the grace period" do
      let!(:subscription) { create(:subscription, :past_due, user: user) }

      it "does not offer a renewal" do
        visit_profile

        expect(response.body).to include(I18n.t("subscription.payment_could_not_charged"))
        expect(response.body).not_to include(I18n.t("subscription.renew"))
      end
    end

    context "when the grace period has run out" do
      let!(:subscription) { create(:subscription, :past_due_expired, user: user) }

      it "offers a renewal" do
        visit_profile

        expect(response.body).to include(I18n.t("subscription.renew"))
      end
    end
  end
end
