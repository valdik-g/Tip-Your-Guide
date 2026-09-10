module Users
  class CreateService
    LOCK_TIMEOUT = 30

    class LockIsNotAcquiredError < StandardError; end

    def self.with_lock(email:, &block)
      User.with_advisory_lock!(lock_name(email:), {timeout_seconds: 30}) do
        yield
      end
    end

    def self.lock_name(email:)
      "users-create-#{email}"
    end

    def initialize(email:, full_name:, country:, city:, password:, password_confirmation:, role:)
      @email = email
      @full_name = full_name
      @country = country
      @city = city
      @password = password
      @password_confirmation = password_confirmation
      @role = role
    end

    def call
      raise LockIsNotAcquiredError unless User.advisory_lock_exists?(self.class.lock_name(email:))
      User.transaction do
        user = User.create(
          email: email,
          password: password,
          password_confirmation: password_confirmation,
          full_name: full_name,
          country: country,
          city: city
        )
        user.add_role(role.name) if user.persisted?

        user
      end
    end

    private

    attr_reader :email, :full_name, :country, :city, :password, :password_confirmation, :role
  end
end
