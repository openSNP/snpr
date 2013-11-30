class AddReferences < ActiveRecord::Migration
  def change
    create_table :references do |t|
      t.integer :snp_id
      t.integer :paper_id
      t.string  :paper_type
      t.timestamps
    end
  end
end
