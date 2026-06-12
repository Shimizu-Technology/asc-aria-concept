class CreateKnowledgeEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :knowledge_entries do |t|
      t.string :title, null: false
      t.string :category, null: false
      t.text :content, null: false
      t.string :source_label, null: false, default: "Seeded prototype data"
      t.string :source_url
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :knowledge_entries, :category
    add_index :knowledge_entries, :active
    add_index :knowledge_entries, [ :category, :title ], unique: true
  end
end
