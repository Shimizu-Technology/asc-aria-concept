class HardenSecureHandoffConstraints < ActiveRecord::Migration[8.1]
  def change
    add_index :secure_access_sessions, :handoff_token_id, unique: true, name: "idx_secure_access_sessions_unique_handoff"
    add_index :secure_chat_sessions, :handoff_token_id, unique: true, name: "idx_secure_chat_sessions_unique_handoff"
  end
end
