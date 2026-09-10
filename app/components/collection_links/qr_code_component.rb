# frozen_string_literal: true

class CollectionLinks::QrCodeComponent < ApplicationComponent
  def initialize(link:, qr_code:)
    @link = link
    @qr_code = qr_code
  end
end
