module Home
  module Features
    class SecretSpotsComponent < ApplicationComponent
      def secret_spots_image
        return sample_image unless Rails.env.production?

        Rails.cache.fetch("home#secret_spots", expires_in: 1.month) do
          Unsplash::Photo.random(query: "Secret Place", count: 1).first.urls.regular
        end
      end
    end
  end
end
