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

ActiveRecord::Schema[8.1].define(version: 2026_06_12_001307) do
  create_table "audit_events", force: :cascade do |t|
    t.string "action", null: false
    t.integer "actor_id"
    t.integer "auditable_id"
    t.string "auditable_type"
    t.datetime "created_at", null: false
    t.json "metadata", default: {}, null: false
    t.datetime "occurred_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_audit_events_on_action"
    t.index ["actor_id"], name: "index_audit_events_on_actor_id"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_events_on_auditable_type_and_auditable_id"
    t.index ["occurred_at"], name: "index_audit_events_on_occurred_at"
  end

  create_table "knowledge_entries", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "category", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.string "source_label", default: "Seeded prototype data", null: false
    t.string "source_url"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_knowledge_entries_on_active"
    t.index ["category", "title"], name: "index_knowledge_entries_on_category_and_title", unique: true
    t.index ["category"], name: "index_knowledge_entries_on_category"
  end

  create_table "participant_profiles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "employer_name", null: false
    t.string "external_identifier"
    t.string "phone"
    t.string "plan_name", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["employer_name"], name: "index_participant_profiles_on_employer_name"
    t.index ["plan_name"], name: "index_participant_profiles_on_plan_name"
    t.index ["user_id"], name: "index_participant_profiles_on_user_id", unique: true
  end

  create_table "plan_rules", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.text "distribution_notes"
    t.date "effective_on"
    t.string "employer_name", null: false
    t.boolean "hardship_allowed", default: false, null: false
    t.boolean "loans_allowed", default: false, null: false
    t.integer "max_active_loans"
    t.integer "max_repayment_years"
    t.string "plan_name", null: false
    t.string "plan_type", null: false
    t.string "source_label", default: "Seeded prototype data", null: false
    t.string "source_url"
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_plan_rules_on_active"
    t.index ["employer_name", "plan_name"], name: "index_plan_rules_on_employer_name_and_plan_name", unique: true
    t.index ["employer_name"], name: "index_plan_rules_on_employer_name"
    t.index ["plan_name"], name: "index_plan_rules_on_plan_name"
    t.index ["plan_type"], name: "index_plan_rules_on_plan_type"
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "staff_profiles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "department", default: "Participant Support", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["department"], name: "index_staff_profiles_on_department"
    t.index ["user_id"], name: "index_staff_profiles_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.integer "role_id", null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
    t.index ["status"], name: "index_users_on_status"
  end

  add_foreign_key "audit_events", "users", column: "actor_id"
  add_foreign_key "participant_profiles", "users"
  add_foreign_key "staff_profiles", "users"
  add_foreign_key "users", "roles"
end
