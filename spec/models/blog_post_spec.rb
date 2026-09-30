require 'rails_helper'

RSpec.describe BlogPost, type: :model do
  describe 'associations' do
    it { should have_one(:blog_post_premium).dependent(:destroy) }
  end

  describe 'nested attributes' do
    it { should accept_nested_attributes_for(:blog_post_premium).allow_destroy(true) }
  end

  describe 'creating blog_post_premium via nested attributes' do
    context 'when both premium attributes are provided' do
      it 'creates a blog_post_premium' do
        expect {
          create(:blog_post, 
                 blog_post_premium_attributes: {
                   premium_title: "Premium Title",
                   premium_content: "Premium Content"
                 })
        }.to change { BlogPostPremium.count }.by(1)
      end

      it 'associates the premium with the blog_post' do
        blog_post = create(:blog_post,
                          blog_post_premium_attributes: {
                            premium_title: "Premium Title",
                            premium_content: "Premium Content"
                          })
        
        expect(blog_post.blog_post_premium).to be_present
        expect(blog_post.blog_post_premium.premium_title).to eq("Premium Title")
      end
    end

    context 'when both premium attributes are blank' do
      it 'does not create a blog_post_premium' do
        expect {
          create(:blog_post,
                 blog_post_premium_attributes: {
                   premium_title: "",
                   premium_content: ""
                 })
        }.to change { BlogPostPremium.count }.by(0)
      end
    end

    context 'when only title is provided' do
      it 'does not create blog_post_premium and adds validation error' do
        blog_post = build(:blog_post,
                         blog_post_premium_attributes: {
                           premium_title: "Premium Title",
                           premium_content: ""
                         })
        
        expect(blog_post).not_to be_valid
        expect(blog_post.errors[:'blog_post_premium.premium_content']).to be_present
      end
    end

    context 'when only content is provided' do
      it 'does not create blog_post_premium and adds validation error' do
        blog_post = build(:blog_post,
                         blog_post_premium_attributes: {
                           premium_title: "",
                           premium_content: "Premium Content"
                         })
        
        expect(blog_post).not_to be_valid
        expect(blog_post.errors[:'blog_post_premium.premium_title']).to be_present
      end
    end
  end

  describe 'updating blog_post_premium via nested attributes' do
    let(:blog_post) { create(:blog_post, :with_premium) }

    context 'when premium attributes are removed' do
      it 'destroys the blog_post_premium when _destroy flag is set' do
        premium_id = blog_post.blog_post_premium.id
        
        expect {
          blog_post.update(
            blog_post_premium_attributes: {
              id: premium_id,
              _destroy: '1'
            }
          )
        }.to change { BlogPostPremium.count }.by(-1)

        expect(blog_post.reload.blog_post_premium).to be_nil
      end
    end

    context 'when premium attributes are updated' do
      it 'updates the existing blog_post_premium' do
        premium_id = blog_post.blog_post_premium.id
        
        expect {
          blog_post.update(
            blog_post_premium_attributes: {
              id: premium_id,
              premium_title: "New Premium Title",
              premium_content: "New Premium Content"
            }
          )
        }.to change { BlogPostPremium.count }.by(0)

        expect(blog_post.reload.blog_post_premium.premium_title).to eq("New Premium Title")
        expect(blog_post.blog_post_premium.premium_content).to eq("New Premium Content")
        expect(blog_post.blog_post_premium.id).to eq(premium_id)
      end
    end

    context 'when updating with only one field' do
      it 'adds validation error when only title is provided' do
        blog_post.assign_attributes(
          blog_post_premium_attributes: {
            id: blog_post.blog_post_premium.id,
            premium_title: "New Title",
            premium_content: ""
          }
        )
        
        expect(blog_post).not_to be_valid
      end
    end
  end

  describe 'destruction' do
    it 'destroys blog_post_premium when blog_post is destroyed' do
      blog_post = create(:blog_post, :with_premium)
      
      expect { blog_post.destroy }.to change { BlogPostPremium.count }.by(-1)
    end
  end

  describe "#author_display_name" do
    context "when the post is linked to a user" do
      it "follows the current name of that user" do
        blog_post = create(:blog_post, :with_author, author_name: "Johnny")
        blog_post.author.update!(full_name: "John Smith")

        expect(blog_post.reload.author_display_name).to eq("John Smith")
      end
    end

    context "when the post is not linked to a user" do
      it "falls back to the stored name" do
        blog_post = create(:blog_post, author_name: "Guest Writer")

        expect(blog_post.author_display_name).to eq("Guest Writer")
      end
    end

    context "when the post is not linked and has no stored name" do
      it "is blank" do
        blog_post = create(:blog_post, author_name: nil)

        expect(blog_post.author_display_name).to be_nil
      end
    end
  end

  describe "the author association" do
    it "is optional" do
      expect(create(:blog_post, author: nil)).to be_persisted
    end

    it "is cleared when the user is destroyed" do
      blog_post = create(:blog_post, :with_author)

      expect { blog_post.author.destroy! }.to change { blog_post.reload.author_id }.from(be_present).to(nil)
    end
  end

  describe "sync_author_name" do
    context "when the author is linked to a user" do
      it "keeps author_name in sync with the user name" do
        blog_post = create(:blog_post, :with_author, author_name: "Stale")
        blog_post.author.update!(full_name: "Jane Doe")

        expect { blog_post.valid? }.to change { blog_post.author_name }.to("Jane Doe")
      end

      it "overwrites a manually typed name" do
        blog_post = build(:blog_post, author_name: "Typed Name")

        blog_post.author = create(:user, full_name: "Linked Author")

        expect { blog_post.valid? }.to change { blog_post.author_name }.to("Linked Author")
      end
    end

    context "when no user is linked" do
      it "keeps the typed author_name untouched" do
        blog_post = build(:blog_post, author_name: "Guest Writer")

        expect(blog_post).to be_valid
        expect(blog_post.author_name).to eq("Guest Writer")
      end
    end
  end
end
