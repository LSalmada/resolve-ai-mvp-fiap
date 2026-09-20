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

ActiveRecord::Schema[8.0].define(version: 2026_09_20_002102) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "occurrence_id", null: false
    t.bigint "user_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["occurrence_id"], name: "index_comments_on_occurrence_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "occurrence_events", force: :cascade do |t|
    t.bigint "occurrence_id", null: false
    t.bigint "user_id", null: false
    t.string "event_type", null: false
    t.string "from_status"
    t.string "to_status"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_type"], name: "index_occurrence_events_on_event_type"
    t.index ["occurrence_id"], name: "index_occurrence_events_on_occurrence_id"
    t.index ["user_id"], name: "index_occurrence_events_on_user_id"
  end

  create_table "occurrences", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.string "location", null: false
    t.string "category", null: false
    t.string "status", default: "aberta", null: false
    t.string "priority", default: "media", null: false
    t.bigint "reporter_id", null: false
    t.bigint "assignee_id"
    t.text "resolution_notes"
    t.integer "rating"
    t.text "rating_comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignee_id"], name: "index_occurrences_on_assignee_id"
    t.index ["category"], name: "index_occurrences_on_category"
    t.index ["priority"], name: "index_occurrences_on_priority"
    t.index ["reporter_id"], name: "index_occurrences_on_reporter_id"
    t.index ["status"], name: "index_occurrences_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name", null: false
    t.string "role", default: "solicitante", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "comments", "occurrences"
  add_foreign_key "comments", "users"
  add_foreign_key "occurrence_events", "occurrences"
  add_foreign_key "occurrence_events", "users"
  add_foreign_key "occurrences", "users", column: "assignee_id"
  add_foreign_key "occurrences", "users", column: "reporter_id"
end
