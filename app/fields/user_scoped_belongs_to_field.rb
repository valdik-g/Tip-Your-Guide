require "administrate/field/belongs_to"

class UserScopedBelongsToField < Administrate::Field::BelongsTo
  def candidate_resources
    scope = associated_class.all

    if resource.respond_to?(:user_id) && resource.user_id.present? && associated_class.column_names.include?("user_id")
      scope = scope.where(user_id: resource.user_id)
    end

    scope
  end

  def options_for_select
    options_from_collection_for_select(
      candidate_resources,
      :id,
      display_candidate_resource,
      selected_option&.id
    )
  end
end
