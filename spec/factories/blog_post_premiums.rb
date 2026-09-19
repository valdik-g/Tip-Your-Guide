FactoryBot.define do
  factory :blog_post_premium do
    premium_title { "Premium Content Title" }
    premium_content { "This is premium content that requires subscription." }
    association :blog_post
  end
end