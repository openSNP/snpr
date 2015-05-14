class DeleteGenotype
  include Sidekiq::Worker
  sidekiq_options queue: :user_snps, retry: 5, unique: true

  def perform(params)
    user_snps = UserSnp.where(genotype_id: params["genotype_id"].to_i)
    # now parse through all user_snps, delete the relevant SNP if the user_snp
    # is the only one, then delete the user_snp
    user_snps.each do |us|
      if us.snp.user_snps.count == 1
        # This user_snp is the only one, so, destroy the Snp,
        # which destroys the UserSnp implicitly
        us.snp.destroy
      end
      us.destroy
    end
  end
end
