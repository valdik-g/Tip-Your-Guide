module AuthenticationHelpers
  def sign_in(user)
    # Create a new session for the user
    session = user.sessions.create!(
      user_agent: "RSpec Test",
      ip_address: "127.0.0.1"
    )
    signed_cookie = CGI.escape(Rails.application.message_verifier("signed cookie").generate(session.id))

    page.driver.browser.set_cookie("session_id=#{signed_cookie}; path=/; HttpOnly; SameSite=Lax")
    Current.session = session
    visit current_path || "/"
  end

  def sign_in_via_form(user)
    visit "/session/new"

    expect(page).to have_content "Sign In"

    within("form") do
      fill_in "Email", with: user.email
      fill_in "Enter your password", with: user.password
    end

    click_button "Sign In"
  end

  def sign_out
    page.driver.browser.clear_cookies
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :feature
end
