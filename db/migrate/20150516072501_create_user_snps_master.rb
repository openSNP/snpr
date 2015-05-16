class CreateUserSnpsMaster < ActiveRecord::Migration
  def change
    create_table :user_snps_master, id: false do |t|
      t.string :snp_name
      t.string :local_genotype, 'char(2)'
    end
  end
end
