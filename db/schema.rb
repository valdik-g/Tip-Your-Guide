# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_15_115455) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "blog_post_premiums", force: :cascade do |t|
    t.bigint "blog_post_id", null: false
    t.datetime "created_at", null: false
    t.text "premium_content"
    t.string "premium_title"
    t.datetime "updated_at", null: false
    t.index ["blog_post_id"], name: "index_blog_post_premiums_on_blog_post_id", unique: true
  end

  create_table "blog_posts", force: :cascade do |t|
    t.string "author_name"
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.string "featured_image"
    t.integer "locale", null: false
    t.string "meta_description", null: false
    t.string "meta_keywords", null: false
    t.boolean "published", default: false
    t.datetime "published_at"
    t.string "slug", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_blog_posts_on_slug", unique: true
  end

  create_table "collection_links", force: :cascade do |t|
    t.json "collection_data"
    t.bigint "collection_id"
    t.datetime "created_at", null: false
    t.string "link", limit: 10, null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "views_count", default: 0, null: false
    t.index ["collection_id"], name: "index_collection_links_on_collection_id"
    t.index ["link"], name: "index_collection_links_on_link", unique: true
    t.index ["user_id"], name: "index_collection_links_on_user_id"
  end

  create_table "collection_places", force: :cascade do |t|
    t.bigint "collection_id", null: false
    t.datetime "created_at", null: false
    t.bigint "place_id", null: false
    t.datetime "updated_at", null: false
    t.index ["collection_id"], name: "index_collection_places_on_collection_id"
    t.index ["place_id"], name: "index_collection_places_on_place_id"
  end

  create_table "collection_prices", force: :cascade do |t|
    t.bigint "collection_id"
    t.datetime "created_at", null: false
    t.integer "currency"
    t.bigint "payment_info_id"
    t.integer "price"
    t.string "stripe_id"
    t.datetime "updated_at", null: false
    t.index ["collection_id"], name: "index_collection_prices_on_collection_id"
    t.index ["payment_info_id"], name: "index_collection_prices_on_payment_info_id"
    t.index ["stripe_id"], name: "index_collection_prices_on_stripe_id"
  end

  create_table "collections", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "places_count", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_collections_on_user_id"
  end

  create_table "google_places", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "external_id", null: false
    t.jsonb "metadata"
    t.bigint "place_id", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id", "place_id"], name: "index_google_places_on_external_id_and_place_id", unique: true
    t.index ["place_id"], name: "index_google_places_on_place_id"
  end

  create_table "payment_infos", force: :cascade do |t|
    t.integer "charge_type", default: 0
    t.datetime "created_at", null: false
    t.string "stripe_product_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["stripe_product_id"], name: "index_payment_infos_on_stripe_product_id", unique: true
    t.index ["user_id", "charge_type"], name: "index_payment_infos_on_user_id_and_charge_type", unique: true
    t.index ["user_id"], name: "index_payment_infos_on_user_id"
  end

  create_table "payment_statuses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "kind", null: false
    t.boolean "last", null: false
    t.bigint "payment_id", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_id"], name: "index_payment_statuses_on_payment_id"
    t.index ["payment_id"], name: "index_payment_statuses_on_payment_id_and_last", unique: true, where: "(last IS TRUE)", include: ["kind"]
  end

  create_table "payments", force: :cascade do |t|
    t.integer "amount", null: false
    t.datetime "created_at", null: false
    t.integer "currency", null: false
    t.string "payer_email"
    t.string "payer_name"
    t.bigint "payment_info_id", null: false
    t.string "stripe_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["payment_info_id"], name: "index_payments_on_payment_info_id"
    t.index ["stripe_id"], name: "index_payments_on_stripe_id", unique: true
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "places", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.string "url"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_places_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.bigint "resource_id"
    t.string "resource_type"
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.boolean "cancel_at_period_end"
    t.datetime "created_at", null: false
    t.datetime "current_period_end"
    t.string "status", default: "incomplete", null: false
    t.string "stripe_customer_id"
    t.string "stripe_subscription_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["stripe_customer_id"], name: "index_subscriptions_on_stripe_customer_id"
    t.index ["stripe_subscription_id"], name: "index_subscriptions_on_stripe_subscription_id", unique: true
    t.index ["user_id"], name: "index_subscriptions_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.text "bio"
    t.string "city"
    t.boolean "collections_enabled", default: true
    t.string "country"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "full_name"
    t.string "interests", default: [], array: true
    t.string "password_digest", null: false
    t.datetime "profile_share_checklist_dismissed_at"
    t.string "slug"
    t.string "time_zone", default: "UTC", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["interests"], name: "index_users_on_interests", using: :gin
    t.index ["slug"], name: "index_users_on_slug", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "user_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  create_table "waitlists", force: :cascade do |t|
    t.string "city"
    t.string "country"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.text "extra_info"
    t.string "full_name"
    t.integer "reason"
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["email"], name: "index_waitlists_on_email", unique: true
    t.index ["user_id"], name: "index_waitlists_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "blog_post_premiums", "blog_posts"
  add_foreign_key "collection_links", "collections"
  add_foreign_key "collection_links", "users"
  add_foreign_key "collection_places", "collections"
  add_foreign_key "collection_places", "places"
  add_foreign_key "collections", "users"
  add_foreign_key "google_places", "places"
  add_foreign_key "payment_infos", "users"
  add_foreign_key "payment_statuses", "payments"
  add_foreign_key "payments", "payment_infos"
  add_foreign_key "payments", "users"
  add_foreign_key "places", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "waitlists", "users"
end
