class CreateUserSnpsMaster < ActiveRecord::Migration
  def up
    remove_index :snps, :name
    add_index :snps, :name, unique: true

    connection.execute(<<-SQL)
      CREATE TABLE user_snps_master (
        snp_name varchar(32) REFERENCES snps (name),
        genotype_id integer REFERENCES genotypes,
        local_genotype char(2) NOT NULL,
        PRIMARY KEY (snp_name, genotype_id)
      )
    SQL
  end

  def down
    drop_table :user_snps_master, force: true
  end
end
