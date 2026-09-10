if Rails.env.development?
  require "rack/livereload"

  # Live reloading configuration
  Rails.application.config.middleware.insert_before ActionDispatch::Static, Rack::LiveReload
  Rails.application.config.middleware.use(Rack::LiveReload,
    min_delay: 1000, # default 1000
    max_delay: 2000, # default 60_000
    live_reload_port: 3002, # default 35729
    live_reload_scheme: "ws", # default ws, use wss for ssl
    host: "127.0.0.1")
end
