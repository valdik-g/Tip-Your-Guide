require "rails_helper"

RSpec.describe TelegramNotifier do
  let(:entry) do
    double(
      "WaitlistEntry",
      email: "test@example.com",
      reason: "guide",
      user_location: "New York",
      extra_info: "Looking for local food spots",
      created_at: Time.current
    )
  end

  let(:notifier) { described_class.new(entry) }

  before do
    stub_const("ENV", ENV.to_hash.merge(
      "TELEGRAM_BOT_TOKEN" => "test_bot_token",
      "TELEGRAM_WAITLIST_CHAT_ID" => "test_waitlist_chat_id",
      "TELEGRAM_PAYMENT_CHAT_ID" => "test_payment_chat_id"
    ))

    # Stub the I18n translation
    allow(I18n).to receive(:t).with("waitlist.reasons.guide").and_return("guide")
  end

  describe "#notify_new_waitlist" do
    let(:message) do
      <<~MESSAGE
        🎉 <b>New Waitlist Entry!</b>

        <b>Email:</b> test@example.com
        <b>Reason:</b> guide
        <b>Location:</b> New York
        <b>Extra info:</b> Looking for local food spots
        <b>Submitted:</b> #{entry.created_at.strftime("%Y-%m-%d %H:%M:%S")}
      MESSAGE
    end

    let(:success_response) do
      double(
        "Response",
        is_a?: true,
        body: {ok: true}.to_json
      )
    end

    let(:error_response) do
      double(
        "Response",
        is_a?: true,
        body: {ok: false, description: "Invalid token"}.to_json
      )
    end

    it "sends a message to Telegram" do
      expect(Net::HTTP).to receive(:post_form).with(
        URI("https://api.telegram.org/bottest_bot_token/sendMessage"),
        {
          chat_id: "test_waitlist_chat_id",
          text: message,
          parse_mode: "HTML",
          disable_web_page_preview: true
        }
      ).and_return(success_response)

      expect(notifier.notify_new_waitlist).to be true
    end

    context "when Telegram API returns an error" do
      it "returns false and logs the error" do
        expect(Net::HTTP).to receive(:post_form).and_return(error_response)
        expect(Rails.logger).to receive(:error).with("Telegram API error: Invalid token")

        expect(notifier.notify_new_waitlist).to be false
      end
    end

    context "when HTTP request fails" do
      let(:failed_response) do
        double(
          "Response",
          is_a?: false,
          code: "500",
          message: "Internal Server Error"
        )
      end

      it "returns false and logs the error" do
        expect(Net::HTTP).to receive(:post_form).and_return(failed_response)
        expect(Rails.logger).to receive(:error).with(
          "Failed to send Telegram notification: 500 - Internal Server Error"
        )

        expect(notifier.notify_new_waitlist).to be false
      end
    end

    context "when JSON parsing fails" do
      it "returns false and logs the error" do
        expect(Net::HTTP).to receive(:post_form).and_return(
          double("Response", is_a?: true, body: "invalid json")
        )
        expect(Rails.logger).to receive(:error).with(/Failed to parse Telegram API response/)

        expect(notifier.notify_new_waitlist).to be false
      end
    end
  end

  describe "#notify_new_payment" do
    let(:entry) do
      {
        name: "John Doe",
        email: "test@example.com",
        phone: "+1234567890",
        telegram: "@john_doe",
        amount: 100,
        currency: "USD",
        metadata: {key: "value"}
      }
    end

    let(:message) do
      <<~MESSAGE
        💰 <b>New Payment!</b>

        <b>Name:</b> John Doe
        <b>Email:</b> test@example.com
        <b>Phone:</b> +1234567890
        <b>Telegram:</b> @john_doe
        <b>Amount:</b> 100 USD
        <b>Metadata:</b> <code>{key: "value"}</code>
      MESSAGE
    end

    let(:success_response) do
      double(
        "Response",
        is_a?: true,
        body: {ok: true}.to_json
      )
    end

    it "sends a message to Telegram" do
      expect(Net::HTTP).to receive(:post_form).with(
        URI("https://api.telegram.org/bottest_bot_token/sendMessage"),
        {
          chat_id: "test_payment_chat_id",
          text: message,
          parse_mode: "HTML",
          disable_web_page_preview: true
        }
      ).and_return(success_response)

      expect(notifier.notify_new_payment).to be true
    end
  end

  describe "#escape_html" do
    it "escapes HTML special characters" do
      expect(notifier.send(:escape_html, "&<>")).to eq("&amp;&lt;&gt;")
    end

    it "returns empty string for blank input" do
      expect(notifier.send(:escape_html, "")).to eq("")
      expect(notifier.send(:escape_html, nil)).to eq("")
    end
  end
end
