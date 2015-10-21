class MoveUserSnpImportSqlIntoDatabase < ActiveRecord::Migration
  def up
    execute(<<-SQL)
      CREATE FUNCTION upsert_user_snps(current_genotype_id integer) RETURNS VOID
      LANGUAGE plpgsql
      AS $$
        DECLARE
          temp_table_name VARCHAR := CONCAT('user_snps_temp_', current_genotype_id::varchar);
          query VARCHAR := FORMAT('SELECT snp_name, local_genotype from %s', temp_table_name);
          temp_record RECORD;
        BEGIN
          FOR temp_record IN EXECUTE(query) LOOP
            BEGIN
              INSERT INTO user_snps (snp_name, genotype_id, local_genotype)
              VALUES (temp_record.snp_name,
                      current_genotype_id,
                      temp_record.local_genotype);
            EXCEPTION WHEN unique_violation THEN
              UPDATE user_snps
              SET local_genotype = temp_record.local_genotype
              WHERE snp_name = temp_record.snp_name
                    AND user_snps.genotype_id = current_genotype_id;
            END;
          END LOOP;
        END;
      $$;
    SQL
  end

  def down
    execute('DROP FUNCTION upsert_user_snps (current_genotype_id integer)')
  end
end
