class CreateStaffProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :staff_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :title, null: false
      t.string :department, null: false, default: "Participant Support"

      t.timestamps
    end

    add_index :staff_profiles, :department
  end
end
