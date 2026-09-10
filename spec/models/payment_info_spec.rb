require "rails_helper"

RSpec.describe PaymentInfo, type: :model do
  describe "charge_type enum" do
    it "scopes collection_purchase rows" do
      user = create(:user)
      collection_pi = create(:payment_info, :collection_purchase, user: user)
      _donation_pi = create(:payment_info, :donation_purchase, user: user)

      expect(described_class.collection_purchase).to contain_exactly(collection_pi)
    end

    it "labels collection_purchase in #display_name" do
      expect(build(:payment_info, :collection_purchase).display_name).to eq("Collection")
    end

    it "labels donation_purchase in #display_name" do
      expect(build(:payment_info, :donation_purchase).display_name).to eq("Tips")
    end
  end

  describe "User#collection_purchase_payment_info" do
    it "returns the collection_purchase row for the user" do
      user = create(:user)
      collection_pi = create(:payment_info, :collection_purchase, user: user)

      expect(user.reload.collection_purchase_payment_info).to eq(collection_pi)
    end
  end
end
