require "rails_helper"

RSpec.describe Users::CreateService do
  let(:role) { create(:role, name: "tour_guide") }
  let(:valid_params) do
    {
      email: "test@example.com",
      full_name: "Test User",
      country: "Test Country",
      city: "Test City",
      password: "password",
      password_confirmation: "password",
      role: role
    }
  end

  describe ".with_lock" do
    it "acquires advisory lock with the correct name" do
      email = "test@example.com"
      lock_name = described_class.lock_name(email: email)

      expect(User).to receive(:with_advisory_lock!).with(lock_name, {timeout_seconds: 30})

      begin
        described_class.with_lock(email: email) {}
      rescue
        nil
      end
    end
  end

  describe ".lock_name" do
    it "returns the correct lock name" do
      expect(described_class.lock_name(email: "test@example.com")).to eq("users-create-test@example.com")
    end
  end

  describe "#call" do
    before do
      allow(User).to receive(:advisory_lock_exists?).and_return(true)
    end

    it "creates a new user with the correct attributes" do
      service = described_class.new(**valid_params)

      expect {
        service.call
      }.to change(User, :count).by(1)

      user = User.last
      expect(user.email).to eq(valid_params[:email])
      expect(user.full_name).to eq(valid_params[:full_name])
      expect(user.country).to eq(valid_params[:country])
      expect(user.city).to eq(valid_params[:city])
    end

    it "assigns the role to the created user" do
      service = described_class.new(**valid_params)
      user = service.call

      expect(user.has_role?(role.name)).to be true
    end

    it "does not assign roles to users that failed to create" do
      invalid_params = valid_params.merge(email: nil)
      service = described_class.new(**invalid_params)
      user = service.call

      expect(user).not_to be_persisted
      expect(user.roles).to be_empty
    end

    it "raises LockIsNotAcquiredError when lock is not acquired" do
      allow(User).to receive(:advisory_lock_exists?).and_return(false)
      service = described_class.new(**valid_params)

      expect {
        service.call
      }.to raise_error(Users::CreateService::LockIsNotAcquiredError)
    end

    it "wraps creation in a transaction" do
      service = described_class.new(**valid_params)

      expect(User).to receive(:transaction).and_call_original

      service.call
    end
  end
end
