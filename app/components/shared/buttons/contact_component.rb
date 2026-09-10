class Shared::Buttons::ContactComponent < Shared::Buttons::ExtendedWidthBaseComponent
  COLORS = "bg-green-100 text-green-600"
  HOVER_STYLES = "hover:bg-green-150"

  def styles
    [
      super,
      COLORS,
      HOVER_STYLES
    ].join(" ")
  end

  def icon_color
    "green-600"
  end
end
