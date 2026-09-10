module DashboardHelper
  def dashboard_money(cents, currency)
    format("%.2f %s", cents.to_i / 100.0, currency.to_s.upcase)
  end

  # Format a 7-day visible-week range as an editorial label.
  # Same month:  "Jun 8 – 14, 2026"
  # Cross month: "Jun 29 – Jul 5, 2026"
  # Cross year:  "Dec 29, 2025 – Jan 4, 2026"
  def dashboard_week_range_label(monday, sunday)
    if monday.year != sunday.year
      "#{monday.strftime("%b %-d, %Y")} – #{sunday.strftime("%b %-d, %Y")}"
    elsif monday.month != sunday.month
      "#{monday.strftime("%b %-d")} – #{sunday.strftime("%b %-d, %Y")}"
    else
      "#{monday.strftime("%b %-d")} – #{sunday.strftime("%-d, %Y")}"
    end
  end
end
