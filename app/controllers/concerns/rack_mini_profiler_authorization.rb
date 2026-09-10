# Refactor: I've disabled RackMiniProfiler for now - not using it that much + not working that great with LiveReload and guard
# See config/initializers/rack_mini_profiler.rb
module RackMiniProfilerAuthorization
  extend ActiveSupport::Concern

  # included do
  #   before_action :authorize_rack_mini_profiler
  # end

  private

  def authorize_rack_mini_profiler
    Rack::MiniProfiler.authorize_request if authorize_rack_mini_profiler?
  end

  def authorize_rack_mini_profiler?
    return true if Rails.env.development?

    current_user&.is_admin?
  end
end
