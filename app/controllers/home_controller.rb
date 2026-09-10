class HomeController < ApplicationController
  skip_before_action :require_authentication, only: :index

  layout "public"

  CACHE_CONFIG = {
    guides: -> { Guide.with_attached_avatar.all },
    total_users: -> { User.count },
    places_count: -> { Place.count },
    payments_count: -> { Payment.count }
  }

  def index
    result = Rails.cache.fetch_multi(*CACHE_CONFIG.keys, expires_in: 1.day) do |key|
      CACHE_CONFIG[key].call
    end
    @guides = result[:guides]
    @total_users = result[:total_users]
    @places_count = result[:places_count]
    @payments_count = result[:payments_count]
  end

  def terms_of_service
  end

  def privacy_policy
  end
end
