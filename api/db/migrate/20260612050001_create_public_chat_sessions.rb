class CreatePublicChatSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :public_chat_sessions do |t|
      t.string :token, null: false
      t.string :status, null: false, default: "open"
      t.string :visitor_label
      t.string :topic
      t.string :detected_intent
      t.boolean :handoff_required, null: false, default: false
      t.string :handoff_reason
      t.json :metadata, null: false, default: {}
      t.datetime :last_message_at

      t.timestamps
    end

    add_index :public_chat_sessions, :token, unique: true
    add_index :public_chat_sessions, :status
    add_index :public_chat_sessions, :detected_intent
    add_index :public_chat_sessions, :handoff_required
    add_index :public_chat_sessions, :last_message_at
  end
end
