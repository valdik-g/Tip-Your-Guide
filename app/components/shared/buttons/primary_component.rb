class Shared::Buttons::PrimaryComponent < Shared::Buttons::BaseComponent
  COLORS = "bg-blue-500 text-white"

  def styles
    [
      super,
      COLORS
    ].join(" ")
  end
end
