class Shared::Buttons::SimpleComponent < Shared::Buttons::BaseComponent
  COLORS = "bg-gray-100"

  def styles
    [
      super,
      COLORS
    ].join(" ")
  end
end
