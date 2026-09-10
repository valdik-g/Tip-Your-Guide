require "capybara/rails"
require "capybara/rspec"
require "selenium/webdriver"

Capybara.server = :puma, {Silent: true}
Capybara.default_max_wait_time = 5

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--headless=new")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-gpu")
  options.add_argument("--window-size=1280,800")
  options.add_argument("--disable-dev-shm-usage") if ENV["CI"]
  options.add_argument("--remote-debugging-port=9222") if ENV["CHROME_DEBUG"]

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: options
  )
end

Capybara.javascript_driver = :headless_chrome
