module PaymentsHelper
  CURRENCY_UNITS = {
    usd: "$",
    eur: "€"
  }
  CENTS_IN_DOLLAR = 100.0

  # Formats the amount with the currency symbol
  # @param amount [Integer] the amount in cents
  # @param currency [String] the currency code based on Payment currency enum
  def amount_with_currency(amount:, currency:)
    number_to_currency(amount / CENTS_IN_DOLLAR,
      unit: currency_unit(currency),
      separator: ",",
      delimiter: "")
  end

  # Format amount when there are multiple currencies
  # @param amount_by_currency [Hash] a hash where keys are currency codes and values are amounts in cents
  # @param divider [String] the string to join the formatted amounts
  def amount_divided_by_currency(amount_by_currency, divider: "/")
    amount_by_currency.map do |currency, amount|
      amount_with_currency(amount:, currency:)
    end.join(divider)
  end

  def currency_unit(currency)
    CURRENCY_UNITS[currency.to_sym]
  end
end
