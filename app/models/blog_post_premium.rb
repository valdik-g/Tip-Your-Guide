class BlogPostPremium < ApplicationRecord
  belongs_to :blog_post, inverse_of: :blog_post_premium

  validates :premium_title, presence: true
  validates :premium_content, presence: true
end
