require 'resque'

class Deletegenotype
   @queue = :deletegenotype

   def self.perform(genotyp)
	  @user_snps = UserSnp.find_all_by_user_id(genotyp["genotype"]["user_id"].to_i)
	  # now parse through all user_snps, delete the relevant SNP if the user_snp is the only one, then delete the user_snp
	  @user_snps.each do |us|
		  @snp = Snp.find_by_name(us.snp_name)
		  if @snp.user_snps.length == 1 # this user_snp is the only one
             Snp.delete(@snp)
		  end
		  UserSnp.delete(us)
	  end
   end
end
