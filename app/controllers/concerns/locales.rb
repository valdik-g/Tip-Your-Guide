module Locales
  extend ActiveSupport::Concern

  included do
    before_action :set_locale
  end

  private

  def set_locale
    # Using english for now
    I18n.locale = :en # extract_locale
  end

  def extract_locale
    return "en" if Rails.env.test?

    browser_locale = params[:locale] || request.env["HTTP_ACCEPT_LANGUAGE"]&.scan(/^[a-z]{2}/)&.first
    return browser_locale if I18n.available_locales.map(&:to_s).include?(browser_locale)

    I18n.default_locale
  end
end
