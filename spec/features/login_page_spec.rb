require "rails_helper"

feature "User opens login page" do
  scenario "they see form title and can sign in" do
    user = create(:user, email: "admin@email.com", password: "password")
    sign_in_via_form(user)

    expect(page.current_path).to eq("/")
  end

  scenario "they see form title and can't sign in with wrong credentials" do
    user = OpenStruct.new(email: "admin@email.com", password: "wrong_password")
    sign_in_via_form(user)

    expect(page).to have_content "Try another email address or password"
  end
end
