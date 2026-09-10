require "administrate/field/has_many"

class UserScopedHasManyField < Administrate::Field::HasMany
  def associated_resource_options
    candidate_resources.map do |resource|
      [display_candidate_resource(resource), resource.id]
    end
  end

  def candidate_resources
    scope = associated_class.all

    if resource.respond_to?(:user_id) && resource.user_id.present? && associated_class.column_names.include?("user_id")
      scope = scope.where(user_id: resource.user_id)
    end

    scope
  end

  def display_candidate_resource(resource)
    associated_dashboard.display_resource(resource)
  end
end
