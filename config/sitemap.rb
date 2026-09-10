# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://tipyour.guide"

# Always store generated files inside the dedicated, writable volume that
# is mounted at /rails/public/sitemaps in production (see config/deploy.yml).
# This avoids EACCES errors when the root /rails/public directory is
# read-only inside the container.
SitemapGenerator::Sitemap.public_path = "/rails/public/sitemaps"
SitemapGenerator::Sitemap.sitemaps_host = "https://tipyour.guide"
SitemapGenerator::Sitemap.sitemaps_path = ""

SitemapGenerator::Sitemap.compress = false

# Skip database access in build environment
is_build_env = ENV["CI"] == "true" || ENV["RAILS_ENV"] == "build"

SitemapGenerator::Sitemap.create do
  # Static pages with high priority
  add "/", changefreq: "daily", priority: 1.0
  add "/home", changefreq: "daily", priority: 1.0
  add "/privacy", changefreq: "monthly", priority: 0.2
  add "/terms_of_service", changefreq: "monthly", priority: 0.2

  # Only include dynamic content when not in build environment
  unless is_build_env
    begin
      if defined?(Role) && ActiveRecord::Base.connection.table_exists?("roles")
        Role.guide.users.find_each do |guide|
          add "/guides/#{guide.slug}",
            lastmod: guide.updated_at,
            changefreq: "daily",
            priority: 0.9
        end
      end

      if defined?(Collection) && ActiveRecord::Base.connection.table_exists?("collections")
        Collection.published.find_each do |collection|
          add "/collections/#{collection.id}",
            lastmod: collection.updated_at,
            changefreq: "daily",
            priority: 0.9
        end
      end

      if defined?(BlogPost) && ActiveRecord::Base.connection.table_exists?("blog_posts")
        BlogPost.published.find_each do |post|
          add "/blog/#{post.locale}/#{post.slug}",
            lastmod: post.updated_at,
            changefreq: "daily",
            priority: 0.8
        end
      end
    rescue ActiveRecord::NoDatabaseError, PG::ConnectionBad => e
      Rails.logger.warn "Database not available for sitemap generation: #{e.message}"
    end
  end
end
