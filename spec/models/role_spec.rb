require "rails_helper"

RSpec.describe Role, type: :model do
  describe "associations" do
    it { is_expected.to have_and_belong_to_many(:users).join_table(:users_roles) }
    it { is_expected.to belong_to(:resource).optional }
  end

  describe "validations" do
    it { is_expected.to validate_inclusion_of(:resource_type).in_array(Rolify.resource_types).allow_nil }
  end

  describe ".guide" do
    context "when guide role exists" do
      let!(:guide_role) { create(:role, name: "guide") }

      it "returns the existing guide role" do
        expect(described_class.guide).to eq(guide_role)
      end
    end

    context "when guide role doesn't exist" do
      it "creates and returns a new guide role" do
        expect { described_class.guide }.to change(Role, :count).by(1)
        expect(described_class.guide.name).to eq("guide")
      end
    end
  end

  describe ".admin" do
    context "when admin role exists" do
      let!(:admin_role) { create(:role, name: "admin") }

      it "returns the existing admin role" do
        expect(described_class.admin).to eq(admin_role)
      end
    end

    context "when admin role doesn't exist" do
      it "creates and returns a new admin role" do
        expect { described_class.admin }.to change(Role, :count).by(1)
        expect(described_class.admin.name).to eq("admin")
      end
    end
  end
end
