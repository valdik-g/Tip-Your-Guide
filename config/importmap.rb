# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "@rails/actiontext", to: "actiontext.esm.js"
pin "trix"

# Tailwind
pin "@tailwindcss/forms", to: "@tailwindcss--forms.js" # @0.5.10
pin "mini-svg-data-uri" # @1.4.4
pin "tailwindcss/colors", to: "tailwindcss--colors.js" # @4.1.4
pin "tailwindcss/defaultTheme", to: "tailwindcss--defaultTheme.js" # @4.1.4
pin "tailwindcss/plugin", to: "tailwindcss--plugin.js" # @4.1.4
pin "@tailwindcss/typography", to: "@tailwindcss--typography.js" # @0.5.16
pin "cssesc" # @3.0.0
pin "lodash.castarray" # @4.4.0
pin "lodash.isplainobject" # @4.0.6
pin "lodash.merge" # @4.6.2
pin "postcss-selector-parser" # @6.0.10
pin "util-deprecate" # @1.0.2

pin_all_from "app/javascript/controllers", under: "controllers"
pin "lib/emoji_spawner", to: "lib/emoji_spawner.js"
