class CreateChatMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :chat_messages do |t|
      t.string :chat_session_type, null: false
      t.integer :chat_session_id, null: false
      t.string :role, null: false
      t.text :content, null: false
      t.json :metadata, null: false, default: {}
      t.datetime :occurred_at, null: false

      t.timestamps
    end

    add_index :chat_messages, [ :chat_session_type, :chat_session_id ]
    add_index :chat_messages, :role
    add_index :chat_messages, :occurred_at
  end
end
