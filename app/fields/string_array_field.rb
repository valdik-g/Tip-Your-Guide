require "administrate/field/base"

class StringArrayField < Administrate::Field::String
  def to_s
    data.join(",")
  end
end
