class ApplicationComponent < ViewComponent::Base
  delegate :current_user, to: :helpers

  def admin?
    current_user&.is_admin?
  end

  def sample_image
    asset_path("road.jpg")
  end
end
