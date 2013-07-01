class DropSnpNameFromUserSnps < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE user_snps
      SET snp_id = snps.id
      FROM snps
      WHERE snp_id is NULL
        AND snps.name = user_snps.snp_name
        AND snp_name is not NULL
    SQL
    remove_column :user_snps, :snp_name
  end

  def down
  end
end
