# copied from https://github.com/antiwork/gumroad/commit/54ff4be189433966377e54abb54bbc751839691a

# Refactor: I've disabled RackMiniProfiler for now - not using it that much + not working that great with LiveReload and guard
# See app/controllers/concerns/rack_mini_profiler_authorization.rb

# require "rack-mini-profiler"

# Rack::MiniProfilerRails.initialize!(Rails.application)
# Rack::MiniProfiler.config.authorization_mode = :allow_authorized

# Rack::MiniProfiler.config.skip_paths = [
#   /\/assets\//,
#   /\/rails\/active_storage\//
# ]

# # When start_hidden is set to true, the mini-profiler UI is initially hidden when the page loads
# # Users can show it by pressing Alt+P (or Option+P on Mac) or by adding ?pp=enable to the URL
# # This is useful in production to avoid distracting regular users while still allowing
# # admins to access profiling data when needed
# Rack::MiniProfiler.config.start_hidden = true

# # Storage instance determines where MiniProfiler stores its profiling data
# # Since we don't have Redis, we'll use the FileStore which saves to disk
# # Other options include MemoryStore (not recommended for production) and MemcacheStore
# Rack::MiniProfiler.config.storage_instance = Rack::MiniProfiler::FileStore.new(
#   path: Rails.root.join("tmp/miniprofiler").to_s,
#   expires_in: 1.hour.in_seconds
# )

# Rack::MiniProfiler.config.user_provider = ->(env) do
#   request = ActionDispatch::Request.new(env)
#   id = request.remote_ip || "unknown"

#   Digest::SHA256.hexdigest(id.to_s)
# end

# # Rack::Headers makes accessing the headers case-insensitive, so
# # headers["Content-Type"] is the same as headers["content-type"]. MiniProfiler
# # specifically looks for "Content-Type" and would skip injecting the profiler
# # if the header is actually "content-type".
# class EnsureHeadersIsRackHeadersObject
#   def initialize(app)
#     @app = app
#   end

#   def call(env)
#     status, headers, body = @app.call(env)
#     response = Rack::Response[status, headers, body]

#     # Debug why the original headers object is sometimes a Hash and sometimes a Rack::Headers object.
#     response.add_header("X-Original-Headers-Class", headers.class.name)

#     response.finish
#   end
# end

# Rails.application.config.middleware.insert_after(
#   Rack::MiniProfiler,
#   EnsureHeadersIsRackHeadersObject
# )
