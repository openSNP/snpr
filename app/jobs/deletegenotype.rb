require 'resque'

class Deletegenotype
   @queue = :deletegenotype

   def self.perform(genotyp)
      @genotype = Genotype.find_by_id(genotyp["genotype"]["id"].to_i)
	  print "deleting genotype" + @genotype.user_id.to_s
	  # find all relevant user_snps
	  @user_snps = UserSnp.where(:user_id => @genotype.user_id)
	  # now parse through all user_snps, delete the relevant SNP if the user_snp is the only one, then delete the user_snp
	  @user_snps.each do |us|
		  @snp = Snp.find_by_id(us.snp_id)
		  if @snp.user_snps.length == 1 # this user_snp is the only one
             Snp.delete(@snp)
		  end
		  UserSnp.delete(us)
	  end
   end
end
