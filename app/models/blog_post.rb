class BlogPost < ApplicationRecord
  enum :locale, {en: 0, ru: 1}

  validates :title, presence: true
  validates :content, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :meta_description, presence: true
  validates :meta_keywords, presence: true

  scope :published, -> { where(published: true) }
end
