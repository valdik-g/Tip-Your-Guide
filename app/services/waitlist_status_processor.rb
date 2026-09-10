class WaitlistStatusProcessor
  attr_reader :waitlist

  def initialize(waitlist)
    @waitlist = waitlist
  end

  def process
    case waitlist.status
    when "rejected" then process_rejection
    when "approved" then process_approval
    end
  end

  private

  def process_rejection
    return if waitlist.user.present?

    WaitlistMailer.rejected(waitlist).deliver_later
  end

  def process_approval
    return if waitlist.user.present?

    User.transaction do
      user = create_user
      assign_guide_role(user)
      send_approval_email(user)
    end
  end

  def create_user
    user = User.create!(
      email: waitlist.email,
      full_name: waitlist.full_name,
      country: waitlist.country,
      city: waitlist.city,
      password: SecureRandom.hex(8)
    )
    waitlist.update!(user: user)
    user
  end

  def assign_guide_role(user)
    user.roles << Role.guide
  end

  def send_approval_email(user)
    token = user.generate_token_for(:password_reset)
    WaitlistMailer.approved(waitlist, token).deliver_later
  end
end
