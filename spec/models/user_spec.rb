require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:sessions).dependent(:destroy) }
    it { is_expected.to have_many(:places).dependent(:nullify) }
    it { is_expected.to have_many(:collections).dependent(:nullify) }
    it { is_expected.to have_many(:payment_infos) }
    it { is_expected.to have_one(:waitlist).dependent(:destroy) }
  end

  describe "validations" do
    subject { create(:user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email) }
    it { is_expected.to validate_presence_of(:password).on(:create) }
    it { is_expected.to validate_presence_of(:full_name) }
    it { is_expected.to validate_presence_of(:country) }
    it { is_expected.to validate_presence_of(:city) }
  end

  describe "callbacks" do
    describe "#generate_slug" do
      context "when slug is not present" do
        let(:user) { build(:user, full_name: "John Doe") }

        it "generates a slug from full name" do
          user.valid?
          expect(user.slug).to eq("john-doe")
        end

        context "when slug already exists" do
          before { create(:user, full_name: "John Doe") }

          it "appends a number to make it unique" do
            user.valid?
            expect(user.slug).to eq("john-doe-2")
          end
        end
      end

      context "when slug is present" do
        let(:user) { build(:user, slug: "custom-slug") }

        it "does not change the slug" do
          user.valid?
          expect(user.slug).to eq("custom-slug")
        end
      end
    end
  end

  describe "#is_guide?" do
    let(:user) { create(:user) }

    context "when user has guide role" do
      before { user.add_role(:guide) }

      it "returns true" do
        expect(user.is_guide?).to be true
      end
    end

    context "when user does not have guide role" do
      it "returns false" do
        expect(user.is_guide?).to be false
      end
    end
  end

  describe "#is_admin?" do
    let(:user) { create(:user) }

    context "when user has admin role" do
      before { user.add_role(:admin) }

      it "returns true" do
        expect(user.is_admin?).to be true
      end
    end

    context "when user does not have admin role" do
      it "returns false" do
        expect(user.is_admin?).to be false
      end
    end
  end

  describe "#to_param" do
    let(:user) { create(:user, full_name: "John Doe") }

    it "returns the slug" do
      expect(user.to_param).to eq(user.slug)
    end
  end
end
