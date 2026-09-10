require "rails_helper"

RSpec.describe WaitlistMailer, type: :mailer do
  let(:waitlist) { create(:waitlist, email: "test@example.com", full_name: "John Doe") }

  describe "#approved" do
    let(:token) { "reset_token_123" }
    let(:mail) { described_class.approved(waitlist, token) }

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t("mailers.waitlist_mailer.approved.subject"))
      expect(mail.to).to eq([waitlist.email])
      expect(mail.from).to eq([ApplicationMailer.default[:from]])
    end

    it "renders the body" do
      html_body = Nokogiri::HTML(mail.body.encoded)
      expect(html_body.at("h1").text.strip).to eq(I18n.t("mailers.waitlist_mailer.approved.subject"))
      expect(html_body.css("p").any? { |p| p.text.strip == I18n.t("mailers.waitlist_mailer.approved.body") }).to be true
      expect(html_body.css("a").any? { |a| a.text.strip == I18n.t("mailers.waitlist_mailer.approved.button") }).to be true
      expect(html_body.at("a[href='#{edit_password_url(token)}']")).to be_present
    end

    it "delivers the email" do
      expect {
        mail.deliver_now
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe "#rejected" do
    let(:mail) { described_class.rejected(waitlist) }

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t("mailers.waitlist_mailer.rejected.subject"))
      expect(mail.to).to eq([waitlist.email])
      expect(mail.from).to eq([ApplicationMailer.default[:from]])
    end

    it "renders the body" do
      html_body = Nokogiri::HTML(mail.body.encoded)
      expect(html_body.at("h1").text.strip).to eq(I18n.t("mailers.waitlist_mailer.rejected.subject"))
      expect(html_body.css("p").any? { |p| p.text.strip == I18n.t("mailers.waitlist_mailer.rejected.body") }).to be true
    end

    it "delivers the email" do
      expect {
        mail.deliver_now
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
