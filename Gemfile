source "https://rubygems.org"

ruby "~> 3.4.9"

gem "rails", "~> 8.1"
gem "propshaft"
gem "pg"
gem "puma"
gem "importmap-rails"
gem "turbo-rails"
gem "hotwire-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem "bootsnap", require: false
gem "rolify"
gem "bcrypt"
gem "countries", require: "countries/global"
gem "stripe"
gem "stripe_event"
gem "rqrcode"
gem "image_processing"
gem "active_storage_validations"
gem "administrate"
gem "posthog-ruby"
gem "sitemap_generator"
gem "google-apis-places_v1"
gem "view_component"
gem "mailtrap"
gem "unsplash"
gem "ostruct"
gem "mission_control-jobs"
gem "lucide-rails"
gem "aws-sdk-s3"
gem "with_advisory_lock"
gem "jwt"
gem "rack-mini-profiler", require: false
gem "rails_cloudflare_turnstile"

group :development, :test do
  gem "pry-rails"
  gem "brakeman", require: false
  gem "bundler-audit", require: false
  gem "letter_opener"
  gem "rack-livereload"
  gem "guard", require: false
  gem "guard-livereload", require: false
  gem "guard-shell", require: false
end

group :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "simplecov", require: false
  gem "capybara"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
end

group :development do
  gem "web-console"
  gem "better_errors"
  gem "binding_of_caller"
  gem "overcommit"
  gem "erb_lint", require: false
end

group :development do
  eval_gemfile "gemfiles/rubocop.gemfile"
end
