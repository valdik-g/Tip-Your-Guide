# Preview all emails at http://localhost:3000/rails/mailers/passwords_mailer

require "factory_bot_rails"

class PasswordsMailerPreview < ActionMailer::Preview
  def reset
    user = User.first || FactoryBot.create(:user)

    PasswordsMailer.reset(user)
  end
end
