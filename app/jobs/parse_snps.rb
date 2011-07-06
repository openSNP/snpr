module Parse
	@queue = :parse

	def parse_snps(genotype)
		genotype_file = File.open(::Rails.root.to_s+"/public/data/"+ @genotype.fs_filename, "r")
		new_snps = genotype_file.readlines
		new_snps.each do |single_snp|
			if single_snp[0] != "#"
				snp_array = single_snp.split("\t")
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
