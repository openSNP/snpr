# frozen_string_literal: true
class AddReferences < ActiveRecord::Migration
  def change
    create_table :snp_references, id: false do |t|
      t.integer :snp_id,     null: false
      t.integer :paper_id,   null: false
      t.string  :paper_type, null: false
    end
    add_index :snp_references, [:snp_id, :paper_id, :paper_type], unique: true
    add_index :snp_references, [:paper_id, :paper_type]
    add_index :snp_references, :snp_id
  end
end
