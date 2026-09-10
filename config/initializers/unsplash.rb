if Rails.application.credentials.unsplash.present?
  Unsplash.configure do |config|
    config.application_access_key = Rails.application.credentials.unsplash[:access_key]
    config.application_secret = Rails.application.credentials.unsplash[:secret_key]
    config.application_redirect_uri = "https://tipyour.guide"
    config.utm_source = "tip_your_guide"
  end
end
