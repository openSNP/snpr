class DeleteGenotype
  include Sidekiq::Worker
  sidekiq_options queue: :user_snps, retry: 5, unique: true

  def perform(params)
    Genotype.find_by!(id: params['genotype_id']).destroy
  end
end
