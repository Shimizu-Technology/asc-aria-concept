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

ActiveRecord::Schema[8.1].define(version: 2026_06_13_010004) do
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

  create_table "chat_messages", force: :cascade do |t|
    t.integer "chat_session_id", null: false
    t.string "chat_session_type", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.json "metadata", default: {}, null: false
    t.datetime "occurred_at", null: false
    t.string "role", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_session_type", "chat_session_id"], name: "index_chat_messages_on_chat_session_type_and_chat_session_id"
    t.index ["occurred_at"], name: "index_chat_messages_on_occurred_at"
    t.index ["role"], name: "index_chat_messages_on_role"
  end

  create_table "handoff_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "detected_employer_or_plan"
    t.datetime "expires_at", null: false
    t.string "intent"
    t.json "metadata", default: {}, null: false
    t.text "original_question"
    t.integer "participant_directory_entry_id"
    t.integer "public_chat_session_id"
    t.string "reason_for_handoff"
    t.string "status", default: "pending", null: false
    t.text "summary"
    t.string "token", null: false
    t.string "topic"
    t.datetime "updated_at", null: false
    t.datetime "used_at"
    t.index ["expires_at"], name: "index_handoff_tokens_on_expires_at"
    t.index ["participant_directory_entry_id"], name: "index_handoff_tokens_on_participant_directory_entry_id"
    t.index ["public_chat_session_id"], name: "index_handoff_tokens_on_public_chat_session_id"
    t.index ["status"], name: "index_handoff_tokens_on_status"
    t.index ["token"], name: "index_handoff_tokens_on_token", unique: true
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

  create_table "outbound_deliveries", force: :cascade do |t|
    t.string "channel", null: false
    t.datetime "created_at", null: false
    t.datetime "delivered_at"
    t.datetime "failed_at"
    t.datetime "last_event_at"
    t.json "metadata", default: {}, null: false
    t.string "provider", null: false
    t.string "provider_error_code"
    t.string "provider_message_id"
    t.string "provider_status_code"
    t.string "provider_status_text"
    t.string "recipient_digest", null: false
    t.string "recipient_masked", null: false
    t.datetime "sent_at"
    t.string "status", default: "queued", null: false
    t.datetime "updated_at", null: false
    t.integer "verification_challenge_id"
    t.index ["channel"], name: "index_outbound_deliveries_on_channel"
    t.index ["provider"], name: "index_outbound_deliveries_on_provider"
    t.index ["provider_message_id"], name: "index_outbound_deliveries_on_provider_message_id"
    t.index ["recipient_digest"], name: "index_outbound_deliveries_on_recipient_digest"
    t.index ["status"], name: "index_outbound_deliveries_on_status"
    t.index ["verification_challenge_id"], name: "index_outbound_deliveries_on_verification_challenge_id"
  end

  create_table "participant_directory_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "display_name", null: false
    t.string "email_digest"
    t.string "email_masked"
    t.string "employer_name", null: false
    t.string "external_identifier", null: false
    t.json "metadata", default: {}, null: false
    t.string "phone_digest"
    t.string "phone_masked"
    t.string "plan_name", null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.index ["email_digest"], name: "idx_participant_directory_on_email_digest", unique: true
    t.index ["employer_name", "plan_name"], name: "idx_participant_directory_on_employer_plan"
    t.index ["external_identifier"], name: "idx_participant_directory_on_external_identifier", unique: true
    t.index ["phone_digest"], name: "idx_participant_directory_on_phone_digest", unique: true
    t.index ["status"], name: "index_participant_directory_entries_on_status"
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

  create_table "public_chat_sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "detected_intent"
    t.string "handoff_reason"
    t.boolean "handoff_required", default: false, null: false
    t.datetime "last_message_at"
    t.json "metadata", default: {}, null: false
    t.string "status", default: "open", null: false
    t.string "token", null: false
    t.string "topic"
    t.datetime "updated_at", null: false
    t.string "visitor_label"
    t.index ["detected_intent"], name: "index_public_chat_sessions_on_detected_intent"
    t.index ["handoff_required"], name: "index_public_chat_sessions_on_handoff_required"
    t.index ["last_message_at"], name: "index_public_chat_sessions_on_last_message_at"
    t.index ["status"], name: "index_public_chat_sessions_on_status"
    t.index ["token"], name: "index_public_chat_sessions_on_token", unique: true
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "secure_access_sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.integer "handoff_token_id", null: false
    t.datetime "last_seen_at"
    t.json "metadata", default: {}, null: false
    t.integer "participant_directory_entry_id", null: false
    t.string "status", default: "active", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_secure_access_sessions_on_expires_at"
    t.index ["handoff_token_id"], name: "idx_secure_access_sessions_unique_handoff", unique: true
    t.index ["handoff_token_id"], name: "index_secure_access_sessions_on_handoff_token_id"
    t.index ["participant_directory_entry_id"], name: "index_secure_access_sessions_on_participant_directory_entry_id"
    t.index ["status"], name: "index_secure_access_sessions_on_status"
    t.index ["token"], name: "index_secure_access_sessions_on_token", unique: true
  end

  create_table "secure_chat_sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "detected_intent"
    t.string "employer_name"
    t.integer "handoff_token_id", null: false
    t.datetime "last_message_at"
    t.json "metadata", default: {}, null: false
    t.integer "participant_directory_entry_id", null: false
    t.string "plan_name"
    t.integer "secure_access_session_id", null: false
    t.string "status", default: "waiting_on_staff", null: false
    t.string "token", null: false
    t.string "topic"
    t.datetime "updated_at", null: false
    t.index ["employer_name", "plan_name"], name: "idx_secure_chat_sessions_on_employer_plan"
    t.index ["handoff_token_id"], name: "idx_secure_chat_sessions_unique_handoff", unique: true
    t.index ["handoff_token_id"], name: "index_secure_chat_sessions_on_handoff_token_id"
    t.index ["last_message_at"], name: "index_secure_chat_sessions_on_last_message_at"
    t.index ["participant_directory_entry_id"], name: "index_secure_chat_sessions_on_participant_directory_entry_id"
    t.index ["secure_access_session_id"], name: "index_secure_chat_sessions_on_secure_access_session_id"
    t.index ["status"], name: "index_secure_chat_sessions_on_status"
    t.index ["token"], name: "index_secure_chat_sessions_on_token", unique: true
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

  create_table "support_requests", force: :cascade do |t|
    t.integer "assigned_staff_id"
    t.datetime "created_at", null: false
    t.datetime "last_activity_at"
    t.json "metadata", default: {}, null: false
    t.integer "participant_directory_entry_id", null: false
    t.string "priority", default: "normal", null: false
    t.integer "secure_chat_session_id", null: false
    t.string "status", default: "needs_relias_lookup", null: false
    t.text "summary"
    t.string "topic"
    t.datetime "updated_at", null: false
    t.index ["assigned_staff_id"], name: "index_support_requests_on_assigned_staff_id"
    t.index ["last_activity_at"], name: "index_support_requests_on_last_activity_at"
    t.index ["participant_directory_entry_id"], name: "index_support_requests_on_participant_directory_entry_id"
    t.index ["priority"], name: "index_support_requests_on_priority"
    t.index ["secure_chat_session_id"], name: "index_support_requests_on_secure_chat_session_id"
    t.index ["status"], name: "index_support_requests_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "accepted_at"
    t.string "clerk_id"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "invitation_status", default: "accepted", null: false
    t.datetime "invited_at"
    t.datetime "last_sign_in_at"
    t.string "name", null: false
    t.integer "role_id", null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.index ["clerk_id"], name: "index_users_on_clerk_id", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_status"], name: "index_users_on_invitation_status"
    t.index ["role_id"], name: "index_users_on_role_id"
    t.index ["status"], name: "index_users_on_status"
  end

  create_table "verification_challenges", force: :cascade do |t|
    t.integer "attempts_count", default: 0, null: false
    t.string "channel", null: false
    t.string "code_digest", null: false
    t.datetime "consumed_at"
    t.string "contact_digest", null: false
    t.string "contact_masked", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.integer "handoff_token_id", null: false
    t.json "metadata", default: {}, null: false
    t.integer "participant_directory_entry_id"
    t.datetime "sent_at"
    t.string "status", default: "pending", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.datetime "verified_at"
    t.index ["channel"], name: "index_verification_challenges_on_channel"
    t.index ["contact_digest"], name: "index_verification_challenges_on_contact_digest"
    t.index ["expires_at"], name: "index_verification_challenges_on_expires_at"
    t.index ["handoff_token_id"], name: "index_verification_challenges_on_handoff_token_id"
    t.index ["participant_directory_entry_id"], name: "idx_on_participant_directory_entry_id_20702ab404"
    t.index ["status"], name: "index_verification_challenges_on_status"
    t.index ["token"], name: "index_verification_challenges_on_token", unique: true
  end

  add_foreign_key "audit_events", "users", column: "actor_id"
  add_foreign_key "handoff_tokens", "participant_directory_entries"
  add_foreign_key "handoff_tokens", "public_chat_sessions"
  add_foreign_key "outbound_deliveries", "verification_challenges"
  add_foreign_key "participant_profiles", "users"
  add_foreign_key "secure_access_sessions", "handoff_tokens"
  add_foreign_key "secure_access_sessions", "participant_directory_entries"
  add_foreign_key "secure_chat_sessions", "handoff_tokens"
  add_foreign_key "secure_chat_sessions", "participant_directory_entries"
  add_foreign_key "secure_chat_sessions", "secure_access_sessions"
  add_foreign_key "staff_profiles", "users"
  add_foreign_key "support_requests", "participant_directory_entries"
  add_foreign_key "support_requests", "secure_chat_sessions"
  add_foreign_key "support_requests", "users", column: "assigned_staff_id"
  add_foreign_key "users", "roles"
  add_foreign_key "verification_challenges", "handoff_tokens"
  add_foreign_key "verification_challenges", "participant_directory_entries"
end
