class AddCompositePrimaryKeys < ActiveRecord::Migration[7.0]
  def change
    change_table(:snp_references, primary_key: %i[snp_id paper_id paper_type]) {}
  end
end
