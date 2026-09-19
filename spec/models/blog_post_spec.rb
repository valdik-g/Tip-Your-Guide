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

    before do
      # Убедимся что premium создан
      blog_post.reload
    end

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
end