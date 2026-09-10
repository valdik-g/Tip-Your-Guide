require "singleton"
require "posthog"

# Analytics. Configured from the environment in this sandbox:
#
#   export POSTHOG_API_KEY=phc_...
#   export POSTHOG_HOST=https://eu.i.posthog.com
#
# With no API key configured, capture is a no-op — the app runs fine without it.
class PosthogClient
  include Singleton

  attr_reader :client

  class << self
    def capture(*args)
      instance.client&.capture(*args)
    end
  end

  def initialize
    api_key = ENV["POSTHOG_API_KEY"]
    return if api_key.blank?

    @client = PostHog::Client.new({
      api_key: api_key,
      host: ENV.fetch("POSTHOG_HOST", "https://eu.i.posthog.com"),
      on_error: proc { |status, msg| Rails.logger.debug msg }
    })
  end
end
