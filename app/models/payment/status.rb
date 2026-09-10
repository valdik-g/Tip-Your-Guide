class Payment
  class Status < ApplicationRecord
    belongs_to :payment
    enum :kind, {no_payment_required: 0, paid: 1, unpaid: 2, refunded: 3}
  end
end
