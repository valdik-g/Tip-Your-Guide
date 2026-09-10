class ApplicationController < ActionController::Base
  include Authentication
  include Authorization
  include RackMiniProfilerAuthorization
  include ContentType

  private

  def scope_for_user(model)
    current_user.is_admin? ? model : current_user.public_send(model.table_name)
  end
end
