# frozen_string_literal: true

namespace :one_time do
  # for zsh use this command format: rake one_time:backfill_payments_for_payment_link\[link_id_here\]
  task :backfill_payments_for_payment_link, [:payment_link] => :environment do |_task, args|
    abort("Pass payment link id as argument") if args.payment_link.blank?
    puts "Scheduling sync jobs for Payment Link:#{args.payment_link}"
    count = 0
    Stripe::Checkout::Session.list({limit: 3, payment_link: args.payment_link}).auto_paging_each do |checkout_session|
      Stripe::Checkout::Sessions::SyncFromProviderJob.perform_later(stripe_id: checkout_session.id)
      count += 1
    end
    puts "Done! Scheduled #{count} jobs for Payment Link:#{args.payment_link}"
  end
end
