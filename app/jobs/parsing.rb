require 'resque' 

class Parsing
	@queue = :parse

	def self.perform(genotyp)
	  @genotype = Genotype.find_by_id(genotyp["genotype"]["id"].to_i)
	  
		genotype_file = File.open(::Rails.root.to_s+"/public/data/"+ @genotype.fs_filename, "r")
		new_snps = genotype_file.readlines
		new_snps.each do |single_snp|
			if single_snp[0][0].chr != "#"
				snp_array = single_snp.split("\t")
				puts snp_array[0]
				  if snp_array.length == (4)
				    if Snp.find_by_name(snp_array[0]) == nil
				      @snp = Snp.new()
				      @snp.name = snp_array[0]
				      @snp.chromosome = snp_array[1]
				      @snp.position = snp_array[2]
				      @snp.save
			      end
			      @user_snp = UserSnp.new()
			      @user_snp.genotype_id = @genotype.id
			      @user_snp.user_id = @genotype.user_id
			      @user_snp.snp_id = @snp.id
			      @user_snp.local_genotype = snp_array[3]
			      @user_snp.save
			    end
		  end
		end
	end
end	
