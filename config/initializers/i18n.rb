I18n.available_locales = [:en] # simplified for now
# I18n.available_locales = [ :en, :ru, :uk, :fr, :de, :es, :zh, :ja, :ko ]

I18n.default_locale = :en

I18n.load_path += Rails.root.glob("config/locales/**/*.{rb,yml}")
