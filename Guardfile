# Guardfile
guard "livereload" do
  # Rails Assets Pipeline
  watch(%r{app/views/.+\.(erb|haml|slim)$})
  watch(%r{app/helpers/.+\.rb})
  watch(%r{app/controllers/.+\.rb})
  watch(%r{app/models/.+\.rb})
  watch(%r{app/components/.+\.(erb|rb)})

  # CSS files
  watch(%r{app/assets/stylesheets/.+\.(css|scss|sass)$})
  watch("app/assets/stylesheets/application.tailwind.css")

  # JavaScript files
  watch(%r{app/javascript/.+\.js$})

  # Config files
  watch("config/routes.rb")
  watch(%r{config/locales/.+\.yml})
end

# Tailwind CSS compilation
guard :shell do
  watch(%r{^app/views/.*\.(erb|haml|slim)$}) do |m|
    `rails tailwindcss:build`
  end

  watch(%r{^app/components/.*\.(erb|rb)$}) do |m|
    `rails tailwindcss:build`
  end

  watch("tailwind.config.js") do |m|
    `rails tailwindcss:build`
  end
end
