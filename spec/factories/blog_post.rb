FactoryBot.define do
  factory :blog_post do
    title { "My Blog Post" }
    content { "This is the content of my blog post." }
    author_name { "John Doe" }
    published_at { Time.current }
    meta_description { "description" }
    meta_keywords { "meta" }
    slug { "my-blog-post-#{SecureRandom.hex(4)}" }
    locale { "en" }

    trait :with_author do
      author { create(:user, full_name: "John Doe") }
    end

    trait :with_premium do
      blog_post_premium_attributes do
        {
          premium_title: "Premium Title",
          premium_content: "Premium Content"
        }
      end
    end
  end
end
