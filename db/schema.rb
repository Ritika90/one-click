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

ActiveRecord::Schema.define(version: 2020_09_16_132509) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "adsets", force: :cascade do |t|
    t.integer "daily_adset_spend"
    t.integer "number_of_adsets"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "currency_exchange_rate", default: "1"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "fb_ads", force: :cascade do |t|
    t.string "uid"
    t.string "campaign_name"
    t.string "interests"
    t.integer "gender"
    t.string "headline"
    t.text "ptext"
    t.string "video_url"
    t.string "thumbnail_url"
    t.string "video_id"
    t.string "countries"
    t.string "creative_id"
    t.string "campaign_id"
    t.string "ad_set_id"
    t.string "ad_id"
    t.integer "result"
    t.string "result_status"
    t.datetime "start_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.datetime "end_time"
    t.string "fb_errors"
  end

  create_table "fb_users", primary_key: "sno", force: :cascade do |t|
    t.string "uid"
    t.string "name"
    t.string "email"
    t.string "token"
    t.string "ad_account_id"
    t.string "page_id"
    t.integer "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "pixel_id"
    t.string "pixel_name"
    t.string "ad_account_name"
    t.string "page_name"
    t.integer "adset_id"
    t.index ["uid"], name: "index_fb_users_on_uid", unique: true
  end

  create_table "products", force: :cascade do |t|
    t.integer "product_id"
    t.string "store_product_id"
    t.string "added_to_store_date"
    t.boolean "is_deleted", default: false, null: false
    t.boolean "is_hidden", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "product_type"
    t.string "shop_domain"
    t.integer "shop_id"
    t.boolean "premium", default: false
    t.index ["shop_domain"], name: "index_products_on_shop_domain"
  end

  create_table "shops", force: :cascade do |t|
    t.string "shopify_domain", null: false
    t.string "shopify_token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "fb_uid"
    t.boolean "subscribe_to_klaviyo", default: false, null: false
    t.boolean "premium", default: false, null: false
    t.index ["fb_uid"], name: "index_shops_on_fb_uid", unique: true
    t.index ["shopify_domain"], name: "index_shops_on_shopify_domain", unique: true
  end

end
