module Admin
  class CollectionsController < Admin::ApplicationController
    # Overwrite any of the RESTful controller actions to implement custom behavior
    # For example, you may want to send an email after a foo is updated.
    #
    # def update
    #   super
    #   send_foo_updated_email(requested_resource)
    # end

    def create
      collection = upsert_collection

      redirect_to after_resource_created_path(collection)
    end

    def update
      collection = upsert_collection

      redirect_to after_resource_updated_path(collection)
    end

    def upsert_collection
      Collections::UpsertService.new(
        id: params[:id],
        title: resource_params[:title],
        description: resource_params[:description],
        user_id: resource_params[:user_id],
        place_ids: resource_params[:place_ids],
        status: resource_params[:status],
        thumbnail: resource_params[:thumbnail],
        collection_price_attributes: resource_params[:collection_price_attributes]
      ).call
    end

    # Override this method to specify custom lookup behavior.
    # This will be used to set the resource for the `show`, `edit`, and `update`
    # actions.
    #
    # def find_resource(param)
    #   Foo.find_by!(slug: param)
    # end

    # The result of this lookup will be available as `requested_resource`

    # Override this if you have certain roles that require a subset
    # this will be used to set the records shown on the `index` action.
    #
    def scoped_resource = maybe_scope_by_user(resource_class)

    # Override `resource_params` if you want to transform the submitted
    # data before it's persisted. For example, the following would turn all
    # empty values into nil values. It uses other APIs such as `resource_class`
    # and `dashboard`:
    #
    def resource_params
      params.require(resource_class.model_name.param_key)
        .permit(dashboard.permitted_attributes(action_name))
        .transform_values { |value| (value == "") ? nil : value }
        .merge!(user_id_param)
    end

    private

    def user_id_param
      if current_user.is_admin?
        (action_name == "create") ? {user_id: current_user.id} : {}
      elsif action_name == "update"
        {user_id: requested_resource.user_id}
      elsif action_name == "create"
        {user_id: current_user.id}
      end
    end

    # See https://administrate-demo.herokuapp.com/customizing_controller_actions
    # for more information
  end
end
