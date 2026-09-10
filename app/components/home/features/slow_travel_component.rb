module Home
  module Features
    class SlowTravelComponent < ApplicationComponent
      def slow_travel_image
        return sample_image unless Rails.env.production?

        Rails.cache.fetch("home#slow_travel", expires_in: 1.month) do
          Unsplash::Photo.random(query: "Slow Travel", count: 1).first.urls.regular
        end
      end
    end
  end
end
