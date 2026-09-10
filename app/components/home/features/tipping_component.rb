module Home
  module Features
    class TippingComponent < ApplicationComponent
      def tipping_payment_platform_image
        return sample_image unless Rails.env.production?

        Rails.cache.fetch("home#tipping_payment_platform", expires_in: 1.month) do
          Unsplash::Photo.random(query: "Tipping", count: 1).first.urls.regular
        end
      end
    end
  end
end
