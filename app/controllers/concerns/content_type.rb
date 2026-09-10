module ContentType
  extend ActiveSupport::Concern

  included do
    before_action :set_content_type
  end

  private

  def set_content_type
    request.format = :html unless params[:format]
  end
end
