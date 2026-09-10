class Collection::Price < ApplicationRecord
  belongs_to :collection
  belongs_to :payment_info

  enum :currency, {usd: 0, eur: 1}
end
