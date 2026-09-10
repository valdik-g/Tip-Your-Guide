class Shared::Buttons::DonateComponent < Shared::Buttons::ExtendedWidthBaseComponent
  COLORS = "bg-green-500 text-white"
  HOVER_STYLES = "hover:bg-green-600"
  EXTRA_STYLES = "px-3 py-3"

  def initialize(**args)
    @guide = args.delete(:guide)
    super
  end

  def styles
    [
      super,
      COLORS,
      HOVER_STYLES,
      EXTRA_STYLES
    ].join(" ")
  end

  def render?
    guide.present? && guide.donation_payment_info.present?
  end

  private

  attr_reader :guide
end
