require 'resque' 

class Parsing
	@queue = :parse

	def self.perform(genotyp)
	  @genotype = Genotype.find_by_id(genotyp["genotype"]["id"].to_i)
	  puts @genotype.fs_filename
	  puts "hello"
	  puts ::Rails.root.to_s
		genotype_file = File.open(::Rails.root.to_s+"/public/data/"+ @genotype.fs_filename, "r")
		new_snps = genotype_file.readlines
		new_snps.each do |single_snp|
			if single_snp[0][0] != "#"
				snp_array = single_snp.split("\t")
				puts snp_array[0]
				  if snp_array.length == (4)
				    @snp = Snp.new()
				    @snp.name = snp_array[0]
				    @snp.chromosome = snp_array[1]
				    @snp.position = snp_array[2]
				    @snp.save
			    	  end
		    	end
		end
	end
end	
