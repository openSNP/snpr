class CreateJoinTablePhenotypeSnp < ActiveRecord::Migration
  def change
    # see rails naming convention for naming JOIN tables
    create_table :phenotype_snps do |t|
      t.references :snp
      t.references :phenotype
      t.float :score, :default => 0
      t.timestamps
    end

    add_index :phenotype_snps, [:snp_id, :phenotype_id], :unique => true
  end
end
