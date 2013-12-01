class RemoveSnpIdFromPapers < ActiveRecord::Migration
  def up
    %w(mendeley snpedia plos genome_gov).each do |source|
      execute(<<-SQL)
        INSERT INTO snp_references (snp_id, paper_type, paper_id, created_at, updated_at)
          (
            SELECT snp_id, '#{source.camelize}Paper', id, now(), now()
            FROM #{source}_papers
            WHERE snp_id IS NOT NULL
          )
      SQL
      #remove_column :"#{source}_papers", :snp_id
    end
  end

  def down
  end
end
