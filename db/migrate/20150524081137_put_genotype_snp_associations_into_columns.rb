class PutGenotypeSnpAssociationsIntoColumns < ActiveRecord::Migration
  def change
    add_column :genotypes, :snps, :hstore, default: '', null: false
    add_column :snps, :genotype_ids, 'int[]', default: [], null: false
  end
end
