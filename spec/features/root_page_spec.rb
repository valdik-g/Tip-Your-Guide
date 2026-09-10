require "rails_helper"

feature "User opens root page" do
  context "when they're not signed in" do
    scenario "they see the title on the page" do
      visit "/"

      expect(page).to have_content "Join Now"
      expect(page).to have_content "Authentic experiences"
    end

    scenario "they can sign up for the waitlist" do
      visit "/"

      fill_in "Your email", with: "new@example.com"
      click_button "Join Now"

      expect(page).to have_content "Thank you for joining!\nWe will contact you shortly"
    end

    scenario "email input and submit button become disabled after successful submit" do
      visit "/"

      fill_in "Your email", with: "new@example.com"
      click_button "Join Now"

      expect(page).to_not have_field "Your email"
      expect(page).to_not have_button "Join Now"
    end

    scenario "they see notice when trying to submit duplicate email" do
      create(:waitlist, email: "test@example.com")

      visit "/"

      fill_in "Your email", with: "test@example.com"
      click_button "Join Now"

      expect(page).to have_content "You are already on the waitlist!"
    end
  end

  context "when they're signed in" do
    let(:user) { create(:user, :guide, :with_payment_info) }

    before do
      sign_in(user)
    end

    scenario "they land on the public home page" do
      expect(page.current_path).to eq("/")
    end
  end
end
