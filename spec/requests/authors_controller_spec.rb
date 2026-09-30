require "rails_helper"

RSpec.describe "Authors", type: :request do
  let(:author) { create(:user, full_name: "John Doe", bio: "A guide from Barcelona") }

  def read_author
    get author_path(author)
  end

  describe "GET /authors/:slug" do
    it "renders the author profile without signing in" do
      read_author

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("John Doe")
      expect(response.body).to include("A guide from Barcelona")
    end

    context "when the slug is unknown" do
      it "returns a not found response" do
        get author_path(slug: "nobody-here")

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the author has articles" do
      let!(:post) { create(:blog_post, :with_author, author: author, published: true, title: "Kyoto in March") }
      let!(:another_post) { create(:blog_post, :with_author, author: author, published: true, title: "Nara day trip") }

      it "links to them" do
        read_author

        expect(response.body).to include("Kyoto in March")
        expect(response.body).to include(blog_post_path(post.locale, post.slug))
        expect(response.body).to include(blog_post_path(another_post.locale, another_post.slug))
      end
    end

    context "when the author only has unpublished articles" do
      let!(:post) { create(:blog_post, :with_author, author: author, published: false, title: "Secret Kyoto") }

      it "does not leak them" do
        read_author

        expect(response.body).not_to include("Secret Kyoto")
      end
    end

    context "when another user has articles" do
      let!(:post) { create(:blog_post, :with_author, title: "Somebody else wrote this") }

      it "does not list them" do
        read_author

        expect(response.body).not_to include("Somebody else wrote this")
      end
    end

    context "when the author has no articles" do
      it "says so" do
        read_author

        expect(response.body).to include(I18n.t("authors.show.no_articles"))
      end
    end
  end
end
