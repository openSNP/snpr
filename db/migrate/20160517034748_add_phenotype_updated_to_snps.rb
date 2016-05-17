class AddPhenotypeUpdatedToSnps < ActiveRecord::Migration
  def change
    add_column :snps, :phenotype_updated, :timestamp
  end
end
