class Home::FormComponent < ApplicationComponent
  include ButtonHelper

  attr_reader :guides, :total_users

  def initialize(guides:, total_users:)
    @guides = guides
    @total_users = total_users
  end

  def guides_count
    t("home.signup_form.users_count", count: total_users)
  end

  def guides_photos
    guides.map do |guide|
      profile_image(guide)
    end.join.html_safe
  end

  def country_options
    ISO3166::Country.translations.invert
  end

  def reason_options
    Waitlist.reasons.keys.map { |reason| [t("waitlist.reasons.#{reason}"), reason] }
  end

  def input_class
    "px-4 py-4 w-full text-base text-gray-900 placeholder-gray-500 ring-1 ring-zinc-950/10 rounded-lg focus:outline-none focus:ring-2 focus:ring-black bg-white [&:invalid]:text-gray-500 [&:invalid]:ring-red-500"
  end

  def submit_button_class
    button_classes(:primary)
  end

  private

  def profile_image(guide)
    classes = "inline-block h-8 w-8 rounded-full ring-2 ring-white border-2 border-blue-500"
    alt = "Guide avatar"

    if guide.avatar.attached?
      image_tag guide.avatar.variant(resize_to_fill: [64, 64]), class: classes, alt: alt
    else
      image_tag asset_path("favicon/favicon.svg"), class: classes, alt: alt
    end
  end
end
