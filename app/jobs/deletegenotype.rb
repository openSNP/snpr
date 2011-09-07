require 'resque'

class Deletegenotype
   @queue = :deletegenotype

   def self.perform(genotyp)
     print genotyp["genotype"]["id"].to_i
     print Genotype.find_by_id(genotyp["genotype"]["id"].to_i)
     @genotype = Genotype.find_by_id(genotyp["genotype"]["id"].to_i) 
     print "got genotype-file\n"
     print @genotype
	  # find all relevant user_snps
	  @user_snps = UserSnp.find_all_by_user_id(@genotype.user_id)
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
