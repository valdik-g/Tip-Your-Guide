require "rails_helper"

RSpec.describe WaitlistStatusProcessor do
  describe "#process" do
    subject(:process) { described_class.new(waitlist).process }

    context "when status changes to rejected" do
      let(:waitlist) { create(:waitlist) }

      before do
        waitlist.status = :rejected
      end

      context "when user does not exist" do
        it "sends rejection email" do
          expect { process }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with("WaitlistMailer", "rejected", "deliver_now", args: [waitlist])
        end
      end

      context "when user exists" do
        let!(:existing_user) { create(:user) }
        let(:waitlist) { create(:waitlist, user: existing_user, status: :rejected) }

        it "does not send rejection email" do
          expect { process }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
        end
      end

      it "does not create a user" do
        expect { process }.not_to change(User, :count)
      end
    end

    context "when status changes to approved" do
      let(:waitlist) { create(:waitlist) }
      let!(:guide_role) { create(:role, name: "guide") }

      before do
        waitlist.status = :approved
      end

      context "when user does not exist" do
        it "creates a user with correct attributes" do
          expect { process }.to change(User, :count).by(1)

          user = User.last
          expect(user.email).to eq(waitlist.email)
          expect(user.full_name).to eq(waitlist.full_name)
          expect(user.country).to eq(waitlist.country)
          expect(user.city).to eq(waitlist.city)
        end

        it "assigns guide role to the user" do
          process
          expect(User.last.roles).to include(guide_role)
        end

        it "associates user with waitlist" do
          process
          expect(waitlist.reload.user).to be_present
        end

        it "sends approval email with password reset token" do
          process
          expect(ActionMailer::MailDeliveryJob)
            .to have_been_enqueued
            .with("WaitlistMailer", "approved", "deliver_now",
              args: [waitlist, kind_of(String)])
        end
      end

      context "when user already exists" do
        let!(:existing_user) { create(:user) }
        let(:waitlist) { create(:waitlist, user: existing_user) }

        it "does not create a new user" do
          expect { process }.not_to change(User, :count)
        end

        it "does not send approval email" do
          expect { process }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
        end
      end
    end

    context "when status changes to contacted" do
      let(:waitlist) { create(:waitlist) }

      before do
        waitlist.status = :contacted
      end

      it "does not send emails or create users" do
        expect { process }.not_to change(User, :count)
        expect { process }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
      end
    end
  end
end
