class RemoveNonuniqueSnpReferences < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute(<<-SQL)
      SELECT DISTINCT * INTO new_table FROM snp_references;
      ALTER TABLE snp_references RENAME TO snp_references_backup;
      ALTER TABLE new_table RENAME TO snp_references;
    SQL
  end
end
