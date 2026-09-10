class Shared::Buttons::BaseComponent < ApplicationComponent
  def initialize(url:, icon_name: nil, icon_color: "gray", extra: "", link_options: {})
    @url = url
    @icon_name = icon_name
    @icon_color = icon_color
    @extra = extra
    @link_options = link_options
  end

  BASE_STYLES = "inline-flex items-center px-4 py-2 font-semibold rounded-md transition-all"
  HOVER_STYLES = "hover:outline-3 hover:outline-dotted hover:outline-gray-600"
  FOCUS_STYLES = "focus:outline-3 focus:outline-dotted focus:outline-blue-600"

  def styles
    [
      BASE_STYLES,
      HOVER_STYLES,
      FOCUS_STYLES,
      extra
    ].join(" ")
  end

  def icon
    helpers.lucide_icon(icon_name, size: 18, color: icon_color)
  end

  private

  attr_reader :url, :icon_name, :icon_color, :extra, :link_options
end
