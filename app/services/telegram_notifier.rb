require "net/http"
require "json"

class TelegramNotifier
  def initialize(record)
    @record = record
  end

  def notify_new_payment
    message = build_payment_message
    chat_id = ENV["TELEGRAM_PAYMENT_CHAT_ID"]

    send_telegram_message(message, chat_id)
  end

  def notify_new_waitlist
    message = build_waitlist_message
    chat_id = ENV["TELEGRAM_WAITLIST_CHAT_ID"]

    send_telegram_message(message, chat_id)
  end

  private

  attr_reader :record

  # Optional in the sandbox. Without a bot token, notifications are skipped.
  #   export TELEGRAM_BOT_TOKEN=...
  #   export TELEGRAM_PAYMENT_CHAT_ID=...
  #   export TELEGRAM_WAITLIST_CHAT_ID=...
  def bot_token
    ENV["TELEGRAM_BOT_TOKEN"]
  end

  def build_waitlist_message
    <<~MESSAGE
      🎉 <b>New Waitlist Entry!</b>

      <b>Email:</b> #{escape_html(record.email)}
      <b>Reason:</b> #{escape_html(I18n.t("waitlist.reasons.#{record.reason}"))}
      <b>Location:</b> #{escape_html(record.user_location)}
      <b>Extra info:</b> #{escape_html(record.extra_info)}
      <b>Submitted:</b> #{escape_html(record.created_at.strftime("%Y-%m-%d %H:%M:%S"))}
    MESSAGE
  end

  def build_payment_message
    <<~MESSAGE
      💰 <b>New Payment!</b>

      <b>Name:</b> #{escape_html(record[:name])}
      <b>Email:</b> #{escape_html(record[:email])}
      <b>Phone:</b> #{escape_html(record[:phone])}
      <b>Telegram:</b> #{escape_html(record[:telegram])}
      <b>Amount:</b> #{escape_html(record[:amount])} #{escape_html(record[:currency])}
      <b>Metadata:</b> <code>#{escape_html(record[:metadata])}</code>
    MESSAGE
  end

  def escape_html(text)
    return "" if text.blank?

    text.to_s.gsub(/[&<>]/, {
      "&" => "&amp;",
      "<" => "&lt;",
      ">" => "&gt;"
    })
  end

  def send_telegram_message(message, chat_id)
    uri = URI("https://api.telegram.org/bot#{bot_token}/sendMessage")

    response = Net::HTTP.post_form(uri, {
      chat_id: chat_id,
      text: message,
      parse_mode: "HTML",
      disable_web_page_preview: true
    })

    handle_response(response)
  end

  def handle_response(response)
    if response.is_a?(Net::HTTPSuccess)
      body = JSON.parse(response.body)
      if body["ok"]
        Rails.logger.info "Telegram notification sent successfully"
        true
      else
        Rails.logger.error "Telegram API error: #{body["description"]}"
        false
      end
    else
      Rails.logger.error "Failed to send Telegram notification: #{response.code} - #{response.message}"
      false
    end
  rescue JSON::ParserError => e
    Rails.logger.error "Failed to parse Telegram API response: #{e.message}"
    false
  rescue => e
    Rails.logger.error "Unexpected error sending Telegram notification: #{e.message}"
    false
  end
end
