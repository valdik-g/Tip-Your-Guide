module Admin
  class BlogPostsController < Admin::ApplicationController
    def create
      @blog_post = BlogPost.new(blog_post_params)

      if @blog_post.save
        redirect_to(
          [namespace, @blog_post],
          notice: translate_with_resource("create.success")
        )
      else
        render :new, status: :unprocessable_entity, locals: {
          page: Administrate::Page::Form.new(dashboard, @blog_post)
        }
      end
    end

    def update
      @blog_post = BlogPost.find(params[:id])

      if @blog_post.update(blog_post_params)
        redirect_to(
          [namespace, @blog_post],
          notice: translate_with_resource("update.success")
        )
      else
        render :edit, status: :unprocessable_entity, locals: {
          page: Administrate::Page::Form.new(dashboard, @blog_post)
        }
      end
    end

    private

    def blog_post_params
      params.require(:blog_post).permit(
        :title, :slug, :locale, :content, :meta_description, :meta_keywords, :published,
        :published_at, :featured_image, :author_name,
        blog_post_premium_attributes: [:id, :premium_title, :premium_content, :_destroy]
      )
    end
    # Overwrite any of the RESTful controller actions to implement custom behavior
    # For example, you may want to send an email after a foo is updated.
    #
    # def update
    #   super
    #   send_foo_updated_email(requested_resource)
    # end

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
    # def scoped_resource
    #   if current_user.super_admin?
    #     resource_class
    #   else
    #     resource_class.with_less_stuff
    #   end
    # end

    # Override `resource_params` if you want to transform the submitted
    # data before it's persisted. For example, the following would turn all
    # empty values into nil values. It uses other APIs such as `resource_class`
    # and `dashboard`:
    #
    # def resource_params
    #   params.require(resource_class.model_name.param_key).
    #     permit(dashboard.permitted_attributes(action_name)).
    #     transform_values { |value| value == "" ? nil : value }
    # end

    # See https://administrate-demo.herokuapp.com/customizing_controller_actions
    # for more information
  end
end
