class CreateParticipantProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :participant_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :employer_name, null: false
      t.string :plan_name, null: false
      t.string :external_identifier
      t.string :phone

      t.timestamps
    end

    add_index :participant_profiles, :employer_name
    add_index :participant_profiles, :plan_name
  end
end
