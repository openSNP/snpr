class AddTablesForGenotypeSnpAssociations < ActiveRecord::Migration
  def change
    remove_index 'snps', 'name'
    add_index 'snps', 'name', unique: true

    create_table 'genotypes_by_snp', id: false do |t|
      t.string 'snp_name', null: false
      t.hstore 'genotypes', null: false, default: {}
    end
    add_index 'genotypes_by_snp', 'snp_name', unique: true
    add_foreign_key 'genotypes_by_snp', 'snps', column: 'snp_name', primary_key: 'name'

    create_table 'snps_by_genotype', id: false do |t|
      t.integer 'genotype_id', null: false
      t.hstore 'snps', null: false, default: {}
    end
    add_index 'snps_by_genotype', 'genotype_id', unique: true
    add_foreign_key 'snps_by_genotype', 'genotypes'
  end
end
