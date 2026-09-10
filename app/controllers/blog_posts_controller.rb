class BlogPostsController < ApplicationController
  skip_before_action :require_authentication

  layout "public"

  def index
    @locale = params[:locale] || I18n.locale
    @blog_posts = BlogPost.where(published: true, locale: @locale).order(published_at: :desc)
  end

  def show
    @blog_post = BlogPost.find_by!(slug: params[:slug])
  end
end
