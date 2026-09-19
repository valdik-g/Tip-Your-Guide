class BlogPostPremium < ApplicationRecord
  belongs_to :blog_post, inverse_of: :blog_post_premium

  validates :premium_title, presence: true, if: :premium_content_present?
  validates :premium_content, presence: true, if: :premium_title_present?

  private

  def premium_title_present?
    premium_title.present?
  end

  def premium_content_present?
    premium_content.present?
  end
end
