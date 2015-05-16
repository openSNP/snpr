class DeleteGenotype
  include Sidekiq::Worker
  sidekiq_options queue: :user_snps, retry: 5, unique: true

  def perform(params)
    ActiveRecord::Base.connection.execute(<<-SQL)
      DROP TABLE IF EXISTS user_snps_#{params["genotype_id"]}
    SQL
  end
end
