class RemoveNonuniqueSnpReferences < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute(<<-SQL)
      SELECT DISTINCT * INTO new_table FROM snp_references;
      ALTER TABLE snp_references RENAME TO snp_references_backup;
      ALTER TABLE new_table RENAME TO snp_references;
      ALTER INDEX index_snp_references_on_snp_id RENAME TO index_snp_references_backup_on_snp_id;
      ALTER INDEX index_snp_references_on_paper_id_and_paper_type RENAME TO index_snp_references_backup_on_paper_id_and_paper_type;
      CREATE INDEX index_snp_references_on_snp_id ON snp_references USING btree (snp_id);
      CREATE INDEX index_snp_references_on_paper_id_and_paper_type ON snp_references USING btree (paper_id, paper_type);
    SQL
  end
end
