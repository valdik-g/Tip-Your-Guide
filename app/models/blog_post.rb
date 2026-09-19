class BlogPost < ApplicationRecord
  enum :locale, {en: 0, ru: 1}
  has_one :blog_post_premium, dependent: :destroy, inverse_of: :blog_post

  accepts_nested_attributes_for :blog_post_premium, 
                                allow_destroy: true, 
                                reject_if: ->(attrs) { 
                                  return false if attrs[:_destroy] == '1' || attrs[:_destroy] == true
                                  
                                  attrs[:premium_title].blank? && attrs[:premium_content].blank?
                                }

  validates :title, presence: true
  validates :content, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :meta_description, presence: true
  validates :meta_keywords, presence: true

  scope :published, -> { where(published: true) } # TODO Fix bug when error creating new blog post and two instances of blog post premium appeares
end
