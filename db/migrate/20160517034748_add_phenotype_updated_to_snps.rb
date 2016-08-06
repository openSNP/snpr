class AddPhenotypeUpdatedToSnps < ActiveRecord::Migration
  def change
    add_column :snps, :phenotype_updated, :timestamp, :default => Time.zone.now-3000000
  end
end
