require "rails_helper"

RSpec.describe "Admin blog post creation", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:author) { create(:user, full_name: "Jane Doe") }

  before { sign_in_as admin }

  def valid_params(overrides = {})
    {
      title: "New Post",
      slug: "post-#{SecureRandom.hex(6)}",
      locale: "en",
      content: "Content",
      meta_description: "description",
      meta_keywords: "meta",
      published: true,
      published_at: Time.current
    }.merge(overrides)
  end

  def created_post
    BlogPost.order(:id).last
  end

  describe "POST /admin/blog_posts" do
    context "when a user is selected in the author dropdown" do
      it "links the post and keeps author_name in sync" do
        post admin_blog_posts_path, params: {
          blog_post: valid_params(author_id: author.id, author_name: "Typed Name")
        }

        expect(response).to redirect_to(admin_blog_post_path(created_post))
        expect(created_post.author).to eq(author)
        expect(created_post.author_name).to eq("Jane Doe")
      end
    end

    context "when the other author option is used" do
      it "stores the typed name without linking a user" do
        post admin_blog_posts_path, params: {
          blog_post: valid_params(author_id: "", author_name: "Guest Writer")
        }

        expect(created_post.author).to be_nil
        expect(created_post.author_name).to eq("Guest Writer")
        expect(created_post.author_id).to be_nil
      end
    end
  end

  describe "GET /admin/blog_posts/:id/edit" do
    it "puts the premium title explanation inside the field as a placeholder" do
      blog_post = create(:blog_post)

      get edit_admin_blog_post_path(blog_post)

      placeholder = I18n.t("administrate.placeholders.blog_post_premium.premium_title")
      expect(response.body).to include(%(placeholder="#{placeholder}"))
    end
  end
end
