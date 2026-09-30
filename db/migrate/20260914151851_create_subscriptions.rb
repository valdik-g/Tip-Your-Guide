class CreateSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :stripe_subscription_id, null: false, index: { unique: true }
      t.string :stripe_customer_id, index: true
      t.string :status, null: false, default: 'incomplete'
      t.datetime :current_period_end

      t.timestamps
    end
  end
end
