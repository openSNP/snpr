class CreateJoinTablePhenotypeSnp < ActiveRecord::Migration
  def self.up
    # see rails naming convention for naming JOIN tables
    create_table :phenotype_snps do |t|
      t.references :snp
      t.references :phenotype
      t.float :score
      t.timestamps
    end
  end

  def self.down
    drop_table :phenotype_snps
  end
end
