# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_05_19_084727) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "crm_items", force: :cascade do |t|
    t.string "email"
    t.datetime "optin_date"
    t.bigint "podcast_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["podcast_id"], name: "index_crm_items_on_podcast_id"
  end

  create_table "episodes", force: :cascade do |t|
    t.string "title"
    t.text "show_notes"
    t.text "transcription"
    t.string "pubDate"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "podcast_id", null: false
    t.string "guid", null: false
    t.text "summary"
    t.string "podcast_title"
    t.json "enclosure"
    t.json "cover_image"
    t.index ["podcast_id"], name: "index_episodes_on_podcast_id"
  end

  create_table "jwt_blacklists", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", null: false
    t.index ["jti"], name: "index_jwt_blacklists_on_jti"
  end

  create_table "podcasts", force: :cascade do |t|
    t.string "title", default: ""
    t.text "description", default: ""
    t.text "audio_player"
    t.string "url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id", null: false
    t.string "subdomain"
    t.string "feed_url", default: ""
    t.string "cover_url", default: ""
    t.json "instagram_access_token"
    t.json "directories"
    t.string "facebook_app_id"
    t.string "financial_support"
    t.index ["user_id"], name: "index_podcasts_on_user_id"
  end

  create_table "themes", force: :cascade do |t|
    t.json "colors"
    t.bigint "podcast_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["podcast_id"], name: "index_themes_on_podcast_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "first_name", default: ""
    t.string "last_name", default: ""
    t.boolean "admin", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "crm_items", "podcasts"
  add_foreign_key "episodes", "podcasts"
  add_foreign_key "podcasts", "users"
  add_foreign_key "themes", "podcasts"
end
