module ApplicationHelper
  def canonical_url
    # Start with the current path
    url = request.path

    # Use the host from configuration in production, or request host in development
    host = if Rails.env.production?
      Rails.application.config.action_controller.default_url_options[:host] || request.host
    else
      request.host_with_port
    end

    # Build the canonical URL with https in production
    protocol = Rails.env.production? ? "https" : request.protocol
    "#{protocol}://#{host}#{url}"
  end

  def under_construction
    if Rails.env.development?
      yield
    end
  end
end
