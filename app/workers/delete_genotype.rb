class DeleteGenotype
  include Sidekiq::Worker
  sidekiq_options queue: :user_snps, retry: 5, unique: true

  def perform(genotype_id)
    connection.transaction do
      connection.execute(<<-SQL)
        UPDATE snps SET genotype_ids =
          (
            SELECT * FROM UNNSEST(genotype_ids) AS genotype_id
            WHERE genotype_id != #{genotype_id}
          )
        WHERE genotype_ids @> ARRAY[#{genotype_id}]
      SQL

      Genotype.find_by(genotype_id).try(:destroy)
    end
  end

  def connection
    ActiveRecord::Base.connection
  end
end
