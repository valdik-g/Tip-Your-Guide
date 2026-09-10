hosts = {
  development: "localhost:3000",
  production: "tipyour.guide"
}.freeze

Rails.application.routes.default_url_options[:host] = hosts[Rails.env.to_sym]
