class Shared::Buttons::ExtendedWidthBaseComponent < Shared::Buttons::BaseComponent
  BASE_STYLES = "w-full justify-center inline-flex items-center px-2 py-2 font-semibold rounded-md transition-all"

  def styles
    [
      super,
      BASE_STYLES
    ].join(" ")
  end
end
