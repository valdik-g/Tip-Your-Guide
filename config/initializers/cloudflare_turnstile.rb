# skip when building docker image

if Rails.env.production? && Rails.application.credentials.dig(:cloudflare, :turnstile, :site_key)
  RailsCloudflareTurnstile.configure do |config|
    config.site_key = Rails.application.credentials.dig(:cloudflare, :turnstile, :site_key)
    config.secret_key = Rails.application.credentials.dig(:cloudflare, :turnstile, :secret_key)

    # In non-production we want the app to continue even if Turnstile fails.
    # In production set to `false` to block suspicious submissions.
    # config.fail_open = !Rails.env.production?

    # Disable entirely when running tests to keep the suite fast.
    config.enabled = Rails.env.production?
  end
end
