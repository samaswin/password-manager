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

ActiveRecord::Schema[8.1].define(version: 2026_01_01_112238) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "audit_logs", force: :cascade do |t|
    t.string "action", null: false
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.inet "ip_address"
    t.jsonb "metadata", default: {}
    t.bigint "password_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["action"], name: "index_audit_logs_on_action"
    t.index ["company_id", "action"], name: "index_audit_logs_on_company_id_and_action"
    t.index ["company_id", "created_at"], name: "index_audit_logs_on_company_id_and_created_at"
    t.index ["company_id"], name: "index_audit_logs_on_company_id"
    t.index ["created_at"], name: "index_audit_logs_on_created_at"
    t.index ["password_id"], name: "index_audit_logs_on_password_id"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "companies", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.boolean "is_admin_company", default: false, null: false
    t.integer "max_users", default: 10
    t.string "name", null: false
    t.string "plan", default: "free"
    t.text "settings"
    t.string "subdomain"
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_companies_on_active"
    t.index ["is_admin_company"], name: "index_companies_on_is_admin_company"
    t.index ["subdomain"], name: "index_companies_on_subdomain", unique: true
  end

  create_table "company_encryption_keys", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.text "encrypted_master_key", null: false
    t.integer "key_version", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "active"], name: "index_company_encryption_keys_on_company_id_and_active"
    t.index ["company_id", "key_version"], name: "index_company_encryption_keys_on_company_id_and_key_version"
    t.index ["company_id"], name: "index_company_encryption_keys_on_company_id"
  end

  create_table "password_shares", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.bigint "password_id", null: false
    t.string "permission_level", default: "read", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["active", "expires_at"], name: "index_password_shares_on_active_and_expires_at"
    t.index ["active"], name: "index_password_shares_on_active"
    t.index ["password_id", "user_id"], name: "index_password_shares_on_password_id_and_user_id", unique: true
    t.index ["password_id"], name: "index_password_shares_on_password_id"
    t.index ["user_id"], name: "index_password_shares_on_user_id"
  end

  create_table "passwords", force: :cascade do |t|
    t.boolean "active", default: true
    t.string "auth_tag"
    t.string "category"
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.text "details"
    t.string "email"
    t.text "encrypted_password"
    t.string "encryption_iv"
    t.string "key"
    t.datetime "last_rotated_at"
    t.string "name", null: false
    t.datetime "password_changed_at"
    t.datetime "password_copied_at"
    t.datetime "password_viewed_at"
    t.string "ssh_finger_print"
    t.text "ssh_private_key"
    t.text "ssh_public_key"
    t.integer "strength_score", default: 0
    t.string "tags", default: [], array: true
    t.datetime "updated_at", null: false
    t.string "url"
    t.string "username"
    t.index ["active"], name: "index_passwords_on_active"
    t.index ["company_id", "active"], name: "index_passwords_on_company_id_and_active"
    t.index ["company_id", "category"], name: "index_passwords_on_company_id_and_category"
    t.index ["company_id"], name: "index_passwords_on_company_id"
    t.index ["created_by_id"], name: "index_passwords_on_created_by_id"
    t.index ["name"], name: "index_passwords_on_name"
    t.index ["tags"], name: "index_passwords_on_tags", using: :gin
  end

  create_table "security_events", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.jsonb "details", default: {}
    t.string "event_type", null: false
    t.boolean "resolved", default: false, null: false
    t.string "severity", default: "low", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["company_id", "resolved"], name: "index_security_events_on_company_id_and_resolved"
    t.index ["company_id"], name: "index_security_events_on_company_id"
    t.index ["event_type"], name: "index_security_events_on_event_type"
    t.index ["resolved"], name: "index_security_events_on_resolved"
    t.index ["severity"], name: "index_security_events_on_severity"
    t.index ["user_id"], name: "index_security_events_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "active"
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "last_password_change_at"
    t.datetime "password_expires_at"
    t.jsonb "preferences", default: {}
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role", default: "user", null: false
    t.boolean "two_factor_enabled", default: false
    t.string "two_factor_secret"
    t.datetime "updated_at", null: false
    t.index ["company_id", "role"], name: "index_users_on_company_id_and_role"
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "audit_logs", "companies"
  add_foreign_key "audit_logs", "passwords"
  add_foreign_key "audit_logs", "users"
  add_foreign_key "company_encryption_keys", "companies"
  add_foreign_key "password_shares", "passwords"
  add_foreign_key "password_shares", "users"
  add_foreign_key "passwords", "companies"
  add_foreign_key "passwords", "users", column: "created_by_id"
  add_foreign_key "security_events", "companies"
  add_foreign_key "security_events", "users"
  add_foreign_key "users", "companies"
end
