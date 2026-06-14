class CreateSecureSupportHandoffModels < ActiveRecord::Migration[8.1]
  def change
    create_table :participant_directory_entries do |t|
      t.string :external_identifier, null: false
      t.string :display_name, null: false
      t.string :email
      t.string :email_digest
      t.string :phone
      t.string :phone_e164
      t.string :phone_digest
      t.string :employer_name, null: false
      t.string :plan_name, null: false
      t.string :status, null: false, default: "active"
      t.json :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :participant_directory_entries, :external_identifier, unique: true, name: "idx_participant_directory_on_external_identifier"
    add_index :participant_directory_entries, :email_digest, unique: true, name: "idx_participant_directory_on_email_digest"
    add_index :participant_directory_entries, :phone_digest, unique: true, name: "idx_participant_directory_on_phone_digest"
    add_index :participant_directory_entries, :status
    add_index :participant_directory_entries, [ :employer_name, :plan_name ], name: "idx_participant_directory_on_employer_plan"

    create_table :handoff_tokens do |t|
      t.references :public_chat_session, foreign_key: true
      t.references :participant_directory_entry, foreign_key: true
      t.string :token, null: false
      t.string :status, null: false, default: "pending"
      t.string :intent
      t.string :topic
      t.string :detected_employer_or_plan
      t.string :reason_for_handoff
      t.text :original_question
      t.text :summary
      t.datetime :expires_at, null: false
      t.datetime :used_at
      t.json :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :handoff_tokens, :token, unique: true
    add_index :handoff_tokens, :status
    add_index :handoff_tokens, :expires_at

    create_table :verification_challenges do |t|
      t.references :handoff_token, null: false, foreign_key: true
      t.references :participant_directory_entry, foreign_key: true
      t.string :token, null: false
      t.string :channel, null: false
      t.string :contact_digest, null: false
      t.string :contact_masked, null: false
      t.string :code_digest, null: false
      t.string :status, null: false, default: "pending"
      t.integer :attempts_count, null: false, default: 0
      t.datetime :expires_at, null: false
      t.datetime :sent_at
      t.datetime :verified_at
      t.datetime :consumed_at
      t.json :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :verification_challenges, :token, unique: true
    add_index :verification_challenges, :channel
    add_index :verification_challenges, :contact_digest
    add_index :verification_challenges, :status
    add_index :verification_challenges, :expires_at

    create_table :outbound_deliveries do |t|
      t.references :verification_challenge, foreign_key: true
      t.string :channel, null: false
      t.string :provider, null: false
      t.string :recipient_digest, null: false
      t.string :recipient_masked, null: false
      t.string :provider_message_id
      t.string :status, null: false, default: "queued"
      t.string :provider_status_code
      t.string :provider_status_text
      t.string :provider_error_code
      t.datetime :last_event_at
      t.datetime :sent_at
      t.datetime :delivered_at
      t.datetime :failed_at
      t.json :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :outbound_deliveries, :channel
    add_index :outbound_deliveries, :provider
    add_index :outbound_deliveries, :recipient_digest
    add_index :outbound_deliveries, :status
    add_index :outbound_deliveries, :provider_message_id

    create_table :secure_access_sessions do |t|
      t.references :participant_directory_entry, null: false, foreign_key: true
      t.references :handoff_token, null: false, foreign_key: true
      t.string :token, null: false
      t.string :status, null: false, default: "active"
      t.datetime :expires_at, null: false
      t.datetime :last_seen_at
      t.json :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :secure_access_sessions, :token, unique: true
    add_index :secure_access_sessions, :status
    add_index :secure_access_sessions, :expires_at

    create_table :secure_chat_sessions do |t|
      t.references :participant_directory_entry, null: false, foreign_key: true
      t.references :secure_access_session, null: false, foreign_key: true
      t.references :handoff_token, null: false, foreign_key: true
      t.string :token, null: false
      t.string :status, null: false, default: "waiting_on_staff"
      t.string :topic
      t.string :employer_name
      t.string :plan_name
      t.string :detected_intent
      t.datetime :last_message_at
      t.json :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :secure_chat_sessions, :token, unique: true
    add_index :secure_chat_sessions, :status
    add_index :secure_chat_sessions, :last_message_at
    add_index :secure_chat_sessions, [ :employer_name, :plan_name ], name: "idx_secure_chat_sessions_on_employer_plan"

    create_table :support_requests do |t|
      t.references :secure_chat_session, null: false, foreign_key: true
      t.references :participant_directory_entry, null: false, foreign_key: true
      t.references :assigned_staff, foreign_key: { to_table: :users }
      t.string :status, null: false, default: "needs_relias_lookup"
      t.string :priority, null: false, default: "normal"
      t.string :topic
      t.text :summary
      t.datetime :last_activity_at
      t.json :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :support_requests, :status
    add_index :support_requests, :priority
    add_index :support_requests, :last_activity_at
  end
end
