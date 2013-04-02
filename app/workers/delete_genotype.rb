class DeleteGenotype
  include Sidekiq::Worker
  sidekiq_options :queue => :deletegenotype, :retry => 5

  def perform(params)
    user_snps = UserSnp.where(genotype_id: params["genotype_id"].to_i).all
    # now parse through all user_snps, delete the relevant SNP if the user_snp
    # is the only one, then delete the user_snp
    user_snps.each do |us|
        if UserSnp.where(snp_name: us.snp_name).count == 1
            # This user_snp is the only one, so, destroy the Snp,
            # which destroys the UserSnp implicitly
            Snp.where(name: us.snp_name).destroy_all
        else
        end
        UserSnp.delete(us)
    end
  end
end
