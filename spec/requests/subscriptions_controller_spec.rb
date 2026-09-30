require 'rails_helper'

RSpec.describe 'Subscriptions', type: :request do
  let(:user) { create(:user) }

  before { sign_in_as user }

  describe 'POST /subscription' do
    it 'redirects to Stripe checkout' do
      allow_any_instance_of(Subscriptions::CreateService).to receive(:call).and_return(
        'https://checkout.stripe.com/test'
      )

      post subscription_path

      expect(response).to redirect_to('https://checkout.stripe.com/test')
    end

    context 'when the previous subscription is canceled' do
      let!(:subscription) { create(:subscription, :canceled_expired, user: user) }

      it 'sends the user to a new checkout' do
        allow_any_instance_of(Subscriptions::CreateService).to receive(:call).and_return(
          'https://checkout.stripe.com/test'
        )

        post subscription_path

        expect(response).to redirect_to('https://checkout.stripe.com/test')
      end

      it 'reuses the Stripe customer of the previous subscription' do
        captured = nil
        checkout = instance_double(
          Stripe::Checkout::Session,
          url: 'https://checkout.stripe.com/test'
        )
        allow(Stripe::Checkout::Session).to receive(:create) do |**params|
          captured = params
          checkout
        end

        post subscription_path

        expect(captured[:customer]).to eq(subscription.stripe_customer_id)
        expect(captured[:subscription_data]).to eq(metadata: {user_id: user.id})
      end
    end

    context 'when a cancelled subscription is still active until the period ends' do
      let!(:subscription) { create(:subscription, :canceled, user: user) }

      it 'refuses the purchase without charging anything' do
        allow_any_instance_of(Subscriptions::CreateService).to receive(:call).and_return(
          'https://checkout.stripe.com/test'
        )

        post subscription_path

        expect(response).to redirect_to(edit_admin_profile_url)
        expect(flash[:alert]).to eq(I18n.t('subscription.flash.already_subscribed'))
      end

      it 'does not open a checkout' do
        allow(Stripe::Checkout::Session).to receive(:create)

        post subscription_path

        expect(Stripe::Checkout::Session).not_to have_received(:create)
      end
    end

    context 'when the subscription is active' do
      let!(:subscription) { create(:subscription, :active, user: user) }

      it 'refuses the purchase' do
        post subscription_path

        expect(response).to redirect_to(edit_admin_profile_url)
        expect(flash[:alert]).to eq(I18n.t('subscription.flash.already_subscribed'))
      end
    end

    context 'when a past_due subscription is inside the grace period' do
      let!(:subscription) { create(:subscription, :past_due, user: user) }

      it 'refuses the purchase' do
        post subscription_path

        expect(response).to redirect_to(edit_admin_profile_url)
        expect(flash[:alert]).to eq(I18n.t('subscription.flash.already_subscribed'))
      end
    end
  end

  describe 'DELETE /subscription' do
    context 'when user has accessible subscription' do
      let!(:subscription) { create(:subscription, user: user, status: 'active') }

      it 'cancels the subscription' do
        allow_any_instance_of(Subscriptions::CancelService).to receive(:call).and_return(subscription)

        delete subscription_path

        expect(response).to redirect_to(edit_admin_profile_url)
        expect(flash[:notice]).to eq(I18n.t('subscription.flash.canceled'))
      end
    end

    context 'when the cancellation fails' do
      let!(:subscription) { create(:subscription, user: user, status: 'active') }

      it 'returns to the profile with an error' do
        allow_any_instance_of(Subscriptions::CancelService).to receive(:call).and_return(nil)

        delete subscription_path

        expect(response).to redirect_to(edit_admin_profile_url)
        expect(flash[:alert]).to eq(I18n.t('subscription.flash.error'))
      end
    end

    context 'when user has no subscription' do
      it 'redirects with error' do
        delete subscription_path

        expect(response).to redirect_to(edit_admin_profile_url)
        expect(flash[:alert]).to eq(I18n.t('subscription.flash.no_active_subscription'))
      end
    end

    context 'when subscription is canceled' do
      let!(:subscription) { create(:subscription, user: user, status: 'canceled') }

      it 'redirects with error' do
        delete subscription_path

        expect(response).to redirect_to(edit_admin_profile_url)
        expect(flash[:alert]).to eq(I18n.t('subscription.flash.no_active_subscription'))
      end
    end
  end

  describe 'GET /subscription/success' do
    it 'redirects to profile with success notice' do
      get success_subscription_path

      expect(response).to redirect_to(edit_admin_profile_url)
      expect(flash[:notice]).to eq(I18n.t('subscription.flash.success'))
    end
  end

  describe 'GET /subscription/cancel' do
    it 'redirects to root with notice' do
      get cancel_subscription_path

      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq(I18n.t('subscription.flash.payment_canceled'))
    end
  end

  describe 'GET /subscription/update_payment_method' do
    context 'when user has accessible subscription' do
      let!(:subscription) { create(:subscription, user: user, status: 'active') }

      it 'redirects to Stripe Billing Portal' do
        allow(Stripe::BillingPortal::Session).to receive(:create).and_return(
          double(url: 'https://billing.stripe.com/test')
        )

        get update_payment_method_subscription_path

        expect(response).to redirect_to('https://billing.stripe.com/test')
      end
    end

    context 'when user has no subscription' do
      it 'redirects with error' do
        get update_payment_method_subscription_path

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(I18n.t('subscription.flash.no_active_subscription'))
      end
    end
  end
end