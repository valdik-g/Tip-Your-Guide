class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :payment_info

  has_many :payment_statuses, class_name: "Payment::Status", dependent: :destroy
  has_one :last_payment_status, -> { where(last: true) }, class_name: "Payment::Status"

  enum :currency, {usd: 0, eur: 1}

  scope :from_latest_payout, ->(latest_payout:) do
    latest_payout.nil? ? all : includes(:payment_info).where("#{table_name}.created_at >= ?", latest_payout.initiated_at)
  end

  def paid?
    last_payment_status.kind == "paid"
  end

  def refunded?
    last_payment_status.kind == "refunded"
  end
end
