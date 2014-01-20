class RemoveIndexFromSnpReferences < ActiveRecord::Migration
  def change
    remove_index :snp_references, [:snp_id, :paper_id, :paper_type]
  end
end
