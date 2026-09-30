require "rails_helper"

RSpec.describe "Stripe webhooks", type: :request do
  let(:signing_secret) { StripeHelper::WEBHOOK_SIGNING_SECRET }
  let(:stripe_subscription_id) { "sub_test" }
  let(:stripe_period_end) { 1.month.from_now }
  let(:user) { create(:user, email: "subscriber@example.com") }

  let(:event) do
    {
      id: "evt_test_123",
      object: "event",
      api_version: "2024-06-20",
      created: Time.current.to_i,
      livemode: false,
      pending_webhooks: 1,
      request: {id: "req_test_123", idempotency_key: "idem_test_123"},
      type: "customer.subscription.updated",
      data: {
        object: {
          id: stripe_subscription_id,
          object: "subscription",
          customer: "cus_test",
          status: "active",
          cancel_at_period_end: false,
          metadata: {user_id: user.id},
          items: {
            object: "list",
            data: [
              {id: "si_test", object: "subscription_item", current_period_end: stripe_period_end.to_i}
            ]
          }
        }
      }
    }
  end

  let(:event_payload) { event.to_json }

  around do |example|
    with_stripe_event_signing_secret(signing_secret) { example.run }
  end

  describe "the signature gate" do
    context "when the signature was made with the webhook signing secret" do
      it "accepts the event" do
        deliver_stripe_webhook(payload: event_payload, signature: stripe_webhook_signature(event_payload))

        expect(response).to have_http_status(:ok)
      end

      it "hands the subscription over to the sync job" do
        expect {
          deliver_stripe_webhook(payload: event_payload, signature: stripe_webhook_signature(event_payload))
        }.to have_enqueued_job(Subscriptions::SyncFromStripeJob)
          .with(stripe_subscription_id: stripe_subscription_id)
      end
    end

    context "when the signature was made with another secret" do
      it "rejects the event" do
        deliver_stripe_webhook(
          payload: event_payload,
          signature: stripe_webhook_signature(event_payload, secret: "whsec_someone_else")
        )

        expect(response).to have_http_status(:bad_request)
      end

      it "does not reach any subscriber" do
        expect {
          deliver_stripe_webhook(
            payload: event_payload,
            signature: stripe_webhook_signature(event_payload, secret: "whsec_someone_else")
          )
        }.not_to have_enqueued_job(Subscriptions::SyncFromStripeJob)
      end
    end

    context "when the Stripe-Signature header is missing" do
      it "rejects the event" do
        deliver_stripe_webhook(payload: event_payload)

        expect(response).to have_http_status(:bad_request)
      end

      it "does not reach any subscriber" do
        expect {
          deliver_stripe_webhook(payload: event_payload)
        }.not_to have_enqueued_job(Subscriptions::SyncFromStripeJob)
      end
    end

    context "when the body no longer matches the signature" do
      it "rejects the event" do
        signature = stripe_webhook_signature(event_payload)
        tampered = event_payload.sub('"status":"active"', '"status":"canceled"')

        deliver_stripe_webhook(payload: tampered, signature: signature)

        expect(response).to have_http_status(:bad_request)
      end

      it "does not reach any subscriber" do
        signature = stripe_webhook_signature(event_payload)
        tampered = event_payload.sub('"status":"active"', '"status":"canceled"')

        expect {
          deliver_stripe_webhook(payload: tampered, signature: signature)
        }.not_to have_enqueued_job(Subscriptions::SyncFromStripeJob)
      end
    end

    context "when the signature is older than the verification tolerance" do
      it "rejects the event" do
        deliver_stripe_webhook(
          payload: event_payload,
          signature: stripe_webhook_signature(event_payload, timestamp: 10.minutes.ago)
        )

        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe "when Stripe redelivers the same event" do
    let!(:subscription) do
      create(
        :subscription,
        :canceled_expired,
        user: user,
        stripe_subscription_id: "sub_previous"
      )
    end

    let(:stripe_subscription) do
      Stripe::Util.convert_to_stripe_object(event[:data][:object].merge(
        customer: {id: "cus_test", object: "customer", email: user.email}
      ))
    end

    before do
      allow(Stripe::Subscription).to receive(:retrieve).and_return(stripe_subscription)
    end

    it "queues the job for every delivery" do
      signature = stripe_webhook_signature(event_payload)

      expect {
        2.times { deliver_stripe_webhook(payload: event_payload, signature: signature) }
      }.to have_enqueued_job(Subscriptions::SyncFromStripeJob).twice
    end

    it "acknowledges both deliveries" do
      signature = stripe_webhook_signature(event_payload)

      2.times { deliver_stripe_webhook(payload: event_payload, signature: signature) }

      expect(response).to have_http_status(:ok)
    end

    it "keeps a single subscription row" do
      signature = stripe_webhook_signature(event_payload)

      perform_enqueued_jobs do
        2.times { deliver_stripe_webhook(payload: event_payload, signature: signature) }
      end

      expect(Subscription.count).to eq(1)
    end

    it "leaves the subscription in the state the event described" do
      signature = stripe_webhook_signature(event_payload)

      perform_enqueued_jobs do
        2.times { deliver_stripe_webhook(payload: event_payload, signature: signature) }
      end

      expect(subscription.reload).to have_attributes(
        stripe_subscription_id: stripe_subscription_id,
        status: "active",
        cancel_at_period_end: false
      )
      expect(subscription.current_period_end).to be_within(1.second).of(stripe_period_end)
    end

    it "does not change the row on the second delivery" do
      signature = stripe_webhook_signature(event_payload)

      perform_enqueued_jobs do
        deliver_stripe_webhook(payload: event_payload, signature: signature)
      end
      after_first_delivery = subscription.reload.attributes.except("updated_at")

      perform_enqueued_jobs do
        deliver_stripe_webhook(payload: event_payload, signature: signature)
      end

      expect(subscription.reload.attributes.except("updated_at")).to eq(after_first_delivery)
      expect(Subscription.count).to eq(1)
    end
  end
end
