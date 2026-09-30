class AuthorsController < ApplicationController
  allow_unauthenticated_access

  layout "public"

  def show
    @author = User.find_by!(slug: params[:slug])
    @blog_posts = @author.blog_posts.published.order(Arel.sql("published_at DESC NULLS LAST"))
  end
end
