module Subscriptions
  class CreateService
    def initialize(user:, success_url:, cancel_url:)
      @user = user
      @success_url = success_url
      @cancel_url = cancel_url
    end

    def call
      session = ::Stripe::Checkout::Session.create(
        mode: "subscription",
        **customer_params,
        line_items: [{
          price: ENV["SUBSCRIPTION_STRIPE_PRICE_ID"],
          quantity: 1
        }],
        subscription_data: {metadata: {user_id: @user.id}},
        success_url: @success_url,
        cancel_url: @cancel_url
      )

      session.url
    end

    private

    attr_reader :user, :success_url, :cancel_url

    def customer_params
      customer_id = user.subscription&.stripe_customer_id

      customer_id ? {customer: customer_id} : {customer_email: user.email}
    end
  end
end
