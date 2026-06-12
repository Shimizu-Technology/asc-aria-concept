class CreateAuditEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_events do |t|
      t.string :action, null: false
      t.integer :actor_id
      t.string :auditable_type
      t.integer :auditable_id
      t.json :metadata, null: false, default: {}
      t.datetime :occurred_at, null: false

      t.timestamps
    end

    add_index :audit_events, :action
    add_index :audit_events, :actor_id
    add_foreign_key :audit_events, :users, column: :actor_id
    add_index :audit_events, [ :auditable_type, :auditable_id ]
    add_index :audit_events, :occurred_at
  end
end
