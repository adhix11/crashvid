# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171011130213) do

  create_table "cart_items", force: :cascade do |t|
    t.integer  "event_video_id", limit: 4
    t.integer  "cart_id",        limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "carts", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "event_videos", force: :cascade do |t|
    t.text     "name",       limit: 65535
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.text     "video",      limit: 65535
    t.integer  "event_id",   limit: 4
    t.integer  "user_id",    limit: 4
    t.integer  "price",      limit: 4,     default: 20
  end

  create_table "events", force: :cascade do |t|
    t.float    "latitude",          limit: 24
    t.float    "longitude",         limit: 24
    t.datetime "date_of_occurence"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "user_id",           limit: 4
    t.string   "location_name",     limit: 255
    t.string   "place_id",          limit: 255
    t.text     "description",       limit: 65535
    t.time     "time_of_occurence"
  end

  create_table "purchases", force: :cascade do |t|
    t.integer  "user_id",             limit: 4
    t.integer  "event_video_id",      limit: 4
    t.text     "paypal_paykey",       limit: 65535
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "payment_status",      limit: 255
    t.text     "user_transaction_id", limit: 65535
    t.float    "amount",              limit: 24
    t.string   "currency_code",       limit: 255
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "spams", force: :cascade do |t|
    t.string   "spam_category",  limit: 255
    t.text     "comment",        limit: 65535
    t.integer  "user_id",        limit: 4
    t.integer  "event_video_id", limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "static_cameras", force: :cascade do |t|
    t.float    "latitude",      limit: 24
    t.float    "longitude",     limit: 24
    t.integer  "user_id",       limit: 4
    t.string   "location_name", limit: 255
    t.string   "place_id",      limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "event_id",   limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "subscriptions", ["event_id"], name: "index_subscriptions_on_event_id", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        limit: 4
    t.integer  "taggable_id",   limit: 4
    t.string   "taggable_type", limit: 255
    t.integer  "tagger_id",     limit: 4
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["context"], name: "index_taggings_on_context", using: :btree
  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy", using: :btree
  add_index "taggings", ["taggable_id"], name: "index_taggings_on_taggable_id", using: :btree
  add_index "taggings", ["taggable_type"], name: "index_taggings_on_taggable_type", using: :btree
  add_index "taggings", ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type", using: :btree
  add_index "taggings", ["tagger_id"], name: "index_taggings_on_tagger_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count", limit: 4,   default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "user_accounts", force: :cascade do |t|
    t.string   "first_name",     limit: 255
    t.string   "last_name",      limit: 255
    t.text     "address_line_1", limit: 65535
    t.string   "country_code",   limit: 255
    t.string   "phone",          limit: 255
    t.integer  "user_id",        limit: 4
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.string   "address_line_2", limit: 255
    t.string   "city",           limit: 255
    t.decimal  "zipcode",                      precision: 10
    t.string   "country",        limit: 255
  end

  add_index "user_accounts", ["user_id"], name: "index_user_accounts_on_user_id", using: :btree

  create_table "user_omniauths", force: :cascade do |t|
    t.string   "provider",         limit: 255
    t.string   "uid",              limit: 255
    t.string   "name",             limit: 255
    t.string   "oauth_token",      limit: 255
    t.datetime "oauth_expires_at"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "user_transactions", force: :cascade do |t|
    t.integer  "user_id",                      limit: 4
    t.text     "paykey",                       limit: 65535
    t.string   "sender_mail_id",               limit: 255
    t.text     "sender_account_id",            limit: 65535
    t.text     "primary_transaction_id",       limit: 65535
    t.string   "primary_transaction_status",   limit: 255
    t.text     "secondary_transaction_id",     limit: 65535
    t.string   "secondary_transaction_status", limit: 255
    t.string   "transaction_status",           limit: 255
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.float    "transaction_amount",           limit: 24
    t.string   "currency_code",                limit: 255
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255,   default: "", null: false
    t.string   "encrypted_password",     limit: 255,   default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,     default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.text     "paypal_paykey",          limit: 65535
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.string   "paypal_email",           limit: 255
    t.string   "provider",               limit: 50,    default: "", null: false
    t.string   "uid",                    limit: 500,   default: "", null: false
    t.integer  "failed_attempts",        limit: 4,     default: 0,  null: false
    t.string   "unlock_token",           limit: 255
    t.datetime "locked_at"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  add_foreign_key "subscriptions", "events"
  add_foreign_key "user_accounts", "users"
end
