class AddReferences < ActiveRecord::Migration
  def change
    create_table :snp_references do |t|
      t.integer :snp_id,     null: false
      t.integer :paper_id,   null: false
      t.string  :paper_type, null: false
      t.timestamps
    end
    add_index :snp_references, [:snp_id, :paper_id, :paper_type], unique: true
  end
end
