require "rails_helper"

RSpec.describe "Home page user icon", type: :request do
  describe "GET /" do
    context "when the visitor is signed in" do
      let(:user) { create(:user) }

      before { sign_in_as user }

      it "links the user icon to the admin profile edit page" do
        get root_path

        expect(response.body).to include(%(href="#{edit_admin_profile_path}"))
        expect(response.body).to include(I18n.t("home.hero.edit_profile"))
      end
    end

    context "when the visitor is signed out" do
      it "links the user icon to the sign in page" do
        get root_path

        expect(response.body).to include(%(href="#{new_session_path}"))
        expect(response.body).to include(I18n.t("home.hero.sign_in"))
      end
    end
  end
end
