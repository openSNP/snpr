class PutGenotypeSnpAssociationsIntoColumns < ActiveRecord::Migration
  def change
    add_column :genotypes, :snps, :hstore, default: {}, null: false
    add_column :snps, :genotypes, :hstore, default: {}, null: false
  end
end
