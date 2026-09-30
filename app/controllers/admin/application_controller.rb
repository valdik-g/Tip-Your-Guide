# All Administrate controllers inherit from this
# `Administrate::ApplicationController`, making it the ideal place to put
# authentication logic or other before_actions.
#
# If you want to add pagination or other controller-level concerns,
# you're free to overwrite the RESTful controller actions.
module Admin
  class ApplicationController < Administrate::ApplicationController
    include Authentication

    helper ButtonHelper

    before_action :require_authentication

    RESOURCES_AVAILABLE_TO_ALL_USERS = [
      Collection, Place, CollectionLink
    ]

    def authorized_action?(resource, action_name)
      return true if current_user.is_admin?

      # Allow guides to edit their own profiles
      return true if resource == current_user && (action_name.to_sym == :edit || action_name.to_sym == :update)

      return RESOURCES_AVAILABLE_TO_ALL_USERS.include?(resource) if action_name.to_sym == :index

      RESOURCES_AVAILABLE_TO_ALL_USERS.include?(resource.class)
    end

    def maybe_scope_by_user(resource_class)
      if current_user.is_admin?
        resource_class
      else
        resource_class.where(user: current_user)
      end
    end

    # Override this value to specify the number of elements to display at a time
    # on index pages. Defaults to 20.
    # def records_per_page
    #   params[:per_page] || 20
    # end
  end
end
