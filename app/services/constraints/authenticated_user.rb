module Constraints
  class AuthenticatedUser
    def self.matches?(request)
      request.cookies["session_id"].present?
    end
  end
end
