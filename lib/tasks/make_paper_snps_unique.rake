namespace :papers do
  task :make_linked_snps_unique => :environment do
    ActiveRecord::Base.connection.execute(<<-SQL)
      SELECT DISTINCT * INTO new_table FROM snp_references;
      ALTER TABLE snp_references RENAME TO snp_references_backup;
      ALTER TABLE new_table RENAME TO snp_references;
    SQL
  end
end
