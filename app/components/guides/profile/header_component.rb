class Guides::Profile::HeaderComponent < ApplicationComponent
  def initialize(guide:)
    @guide = guide
  end

  def profile_image
    if guide.avatar.attached?
      image_tag guide.avatar.variant(resize_to_fill: [512, 512]), class: "w-full h-full object-cover rounded-full border-5 border-black", alt: "Guide Photo"
    else
      image_tag asset_path("favicon/favicon.svg"), class: "w-full h-full object-cover rounded-full border-5 border-black", alt: "Guide Photo"
    end
  end

  def full_name
    guide.full_name
  end

  def subtitle
    t("guides.show.subtitle")
  end

  def location
    [guide.city, Country[guide.country]&.common_name].compact.join(", ")
  end

  def interests
    return guide.interests if guide.interests.present?

    guide.collections.pluck(:title)
  end

  private

  attr_reader :guide
end
