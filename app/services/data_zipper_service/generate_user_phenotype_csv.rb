# frozen_string_literal: true

require 'csv'

class DataZipperService
  class GenerateUserPhenotypeCsv
    def call
      characteristics = phenotypes.pluck(:characteristic)

      # Build a pivot table with characteristics and user IDs as dimensions and
      # variations as values.
      ApplicationRecord.copy_csv(<<-SQL)
        SELECT
          user_id,
          fs_filename AS genotype_filename,
          user_yob AS date_of_birth,
          user_sex AS chrom_sex,
          oh_user_name AS openhumans_name,
          #{characteristics.map { |c| "COALESCE(\"#{c}\", '-') AS \"#{c}\"" }.join(', ')}
        FROM CROSSTAB(
         'SELECT genotypes.user_id, -- vertical dimension, must be first
                 genotypes.user_id || ''.'' || genotypes.filetype || ''.'' || genotypes.id,
                 users.yearofbirth,
                 users.sex,
                 COALESCE(open_humans_profiles.open_humans_user_id, ''-''),
                 phenotypes.characteristic, -- column headers, must be second to last
                 user_phenotypes.variation -- values, must be last
          FROM genotypes
          JOIN users ON users.id = genotypes.user_id
          JOIN user_phenotypes ON user_phenotypes.user_id = genotypes.user_id
          JOIN phenotypes ON phenotypes.id = user_phenotypes.phenotype_id
          LEFT JOIN open_humans_profiles ON open_humans_profiles.user_id = users.id
          ORDER BY user_id',
         '#{phenotypes.to_sql}'
        ) AS ct_variations(
          user_id integer,
          fs_filename text,
          user_yob integer,
          user_sex text,
          oh_user_name text,
          #{characteristics.map { |c| "\"#{c}\" text" }.join(', ')}
        )
      SQL
    end

    private

    def phenotypes
      @phenotypes ||= Phenotype.select(:characteristic).order(:id)
    end
  end
end

