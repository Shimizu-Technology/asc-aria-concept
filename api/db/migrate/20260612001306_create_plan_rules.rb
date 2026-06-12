class CreatePlanRules < ActiveRecord::Migration[8.1]
  def change
    create_table :plan_rules do |t|
      t.string :employer_name, null: false
      t.string :plan_name, null: false
      t.string :plan_type, null: false
      t.boolean :loans_allowed, null: false, default: false
      t.integer :max_active_loans
      t.integer :max_repayment_years
      t.boolean :hardship_allowed, null: false, default: false
      t.text :distribution_notes
      t.string :source_label, null: false, default: "Seeded prototype data"
      t.string :source_url
      t.boolean :active, null: false, default: true
      t.date :effective_on

      t.timestamps
    end

    add_index :plan_rules, :employer_name
    add_index :plan_rules, :plan_name
    add_index :plan_rules, :plan_type
    add_index :plan_rules, :active
    add_index :plan_rules, [ :employer_name, :plan_name ], unique: true
  end
end
