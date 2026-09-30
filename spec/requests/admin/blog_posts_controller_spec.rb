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

    context "when the post has a premium part" do
      let(:blog_post) { create(:blog_post, :with_premium) }

      it "offers a checkbox that removes the premium part" do
        get edit_admin_blog_post_path(blog_post)

        expect(response.body).to include(
          %(name="blog_post[blog_post_premium_attributes][_destroy]")
        )
      end

      it "labels the checkbox" do
        get edit_admin_blog_post_path(blog_post)

        expect(response.body).to include(I18n.t("administrate.actions.destroy_nested"))
      end

      it "sends the unchecked value so the params list always sees the key" do
        get edit_admin_blog_post_path(blog_post)

        expect(response.body).to include(
          %(<input name="blog_post[blog_post_premium_attributes][_destroy]" ) +
            %(type="hidden" value="0" autocomplete="off")
        )
      end
    end

    context "when the post has no premium part" do
      let(:blog_post) { create(:blog_post) }

      it "offers nothing to remove" do
        get edit_admin_blog_post_path(blog_post)

        expect(response.body).not_to include(
          %(name="blog_post[blog_post_premium_attributes][_destroy]")
        )
      end
    end
  end

  describe "PUT /admin/blog_posts/:id" do
    let(:blog_post) { create(:blog_post, :with_premium) }

    def update_post(premium_params)
      patch admin_blog_post_path(blog_post),
        params: {blog_post: {title: blog_post.title, blog_post_premium_attributes: premium_params}}
    end

    context "when the premium part is ticked for removal" do
      it "deletes the premium part" do
        update_post(id: blog_post.blog_post_premium.id.to_s, _destroy: "1")

        expect(response).to redirect_to(admin_blog_post_path(blog_post))
        expect(blog_post.reload.blog_post_premium).to be_nil
      end

      it "deletes it even when the fields are submitted blank" do
        update_post(id: blog_post.blog_post_premium.id.to_s, premium_title: "", premium_content: "", _destroy: "1")

        expect(response).to redirect_to(admin_blog_post_path(blog_post))
        expect(blog_post.reload.blog_post_premium).to be_nil
      end
    end

    context "when the premium part is left alone" do
      it "keeps the row and stores the new values" do
        update_post(id: blog_post.blog_post_premium.id.to_s, premium_title: "New Title", premium_content: "New Content")

        expect(response).to redirect_to(admin_blog_post_path(blog_post))
        expect(blog_post.reload.blog_post_premium).to have_attributes(
          premium_title: "New Title",
          premium_content: "New Content"
        )
      end
    end

    context "when the post has no premium part and the form is submitted blank" do
      let(:blog_post) { create(:blog_post) }

      it "creates nothing" do
        expect {
          update_post(premium_title: "", premium_content: "")
        }.not_to change(BlogPostPremium, :count)

        expect(blog_post.reload.blog_post_premium).to be_nil
      end
    end
  end
end
