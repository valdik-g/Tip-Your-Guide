require "administrate/field/base"

class CurrentUserField < Administrate::Field::Base
  def to_s
    @data.full_name
  end
end
