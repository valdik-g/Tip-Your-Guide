module RequestAuthenticationHelpers
  # Sign in via the real POST /session endpoint so the request spec exercises
  # the same auth path the browser uses. The factory user must have a known
  # password (default "password" in the user factory).
  def sign_in_as(user, password: "password")
    host! "127.0.0.1"
    post "/session", params: {email: user.email, password: password}
    raise "sign_in_as failed for #{user.email}: #{response.status} #{response.body[0, 200]}" unless response.redirect?
  end
end

RSpec.configure do |config|
  config.include RequestAuthenticationHelpers, type: :request
end
