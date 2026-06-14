class AddClerkFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :clerk_id, :string
    add_column :users, :invitation_status, :string, null: false, default: "accepted"
    add_column :users, :invited_at, :datetime
    add_column :users, :accepted_at, :datetime
    add_column :users, :last_sign_in_at, :datetime

    add_index :users, :clerk_id, unique: true
    add_index :users, :invitation_status
  end
end
