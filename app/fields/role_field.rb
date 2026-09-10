require "administrate/field/base"

class RoleField < Administrate::Field::Base
  def to_s
    resource.roles.map { |t| t.name.humanize }.join(", ")
  end
end
