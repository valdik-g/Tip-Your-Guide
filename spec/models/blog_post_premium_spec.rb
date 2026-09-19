require 'rails_helper'

RSpec.describe BlogPostPremium, type: :model do
  describe 'associations' do
    it { should belong_to(:blog_post) }
  end

  describe 'validations' do
    let(:blog_post) { create(:blog_post) }

    context 'when premium_content is present' do
      it 'validates presence of premium_title' do
        premium = build(:blog_post_premium, blog_post: blog_post, premium_content: 'Content', premium_title: nil)
        
        expect(premium).not_to be_valid
        expect(premium.errors[:premium_title]).to include("can't be blank")
      end
    end

    context 'when premium_title is present' do
      it 'validates presence of premium_content' do
        premium = build(:blog_post_premium, blog_post: blog_post, premium_title: 'Title', premium_content: nil)
        
        expect(premium).not_to be_valid
        expect(premium.errors[:premium_content]).to include("can't be blank")
      end
    end

    context 'when both fields are blank' do
      it 'is valid (will be rejected by parent model)' do
        premium = build(:blog_post_premium, blog_post: blog_post, premium_title: nil, premium_content: nil)
        
        expect(premium).to be_valid
      end
    end

    context 'when both fields are present' do
      it 'is valid' do
        premium = build(:blog_post_premium, blog_post: blog_post, premium_title: 'Title', premium_content: 'Content')
        
        expect(premium).to be_valid
      end
    end
  end

  describe 'destruction' do
    it 'is destroyed when parent blog_post is destroyed' do
      blog_post = create(:blog_post)
      premium = create(:blog_post_premium, blog_post: blog_post)
      
      expect { blog_post.destroy }.to change { BlogPostPremium.count }.by(-1)
    end
  end
end