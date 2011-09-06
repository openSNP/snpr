require 'resque' 

class Parsing
	@queue = :parse

	def self.perform(genotyp)
	  @genotype = Genotype.find_by_id(genotyp["genotype"]["id"].to_i)
	  # do we have a normal filetype?
	  if @genotype.filetype != "other"
  		genotype_file = File.open(::Rails.root.to_s+"/public/data/"+ @genotype.fs_filename, "r")
  		new_snps = genotype_file.readlines
		# open that file, go through each line
  		new_snps.each do |single_snp|
  			if single_snp[0].chr != "#"
			  
			  # make a nice array if line is no comment
  			  if @genotype.filetype == "23andme"
  				  snp_array = single_snp.split("\t")
				  
  			  elsif @genotype.filetype == "decodeme"
  			    temp_array = single_snp.split(",")
  			    if temp_array[0] != "Name"
  			      snp_array = [temp_array[0],temp_array[2],temp_array[3],temp_array[5]]
  			    else
  			      snp_array = []
  		      end
		  end
			      
  				puts snp_array[0]
  				  if snp_array.length == (4)
					# if we do not have the fitting SNP, make one and parse all paper-types for it
  				    if Snp.find_by_name(snp_array[0]) == nil
  				      @snp = Snp.new(:name => snp_array[0], :chromosome => snp_array[1], :position => snp_array[2]).save
  				      Resque.enqueue(Plos,@snp)
					  Resque.enqueue(Mendeley,@snp)
					  Resque.enqueue(Snpedia,@snp)
  				    else 
  				      @snp = Snp.find_by_name(snp_array[0])
  			      end

				  # make a new user_snp
  			      @user_snp = UserSnp.new(:genotype_id => @genotype.id, :user_id => @genotype.user_id, :snp_id => @snp.id, :local_genotype => snp_array[3].rstrip).save
				# change allele-frequency and genotype-frequency for each SNP,
				# start with 1 if there is no frequency else just add
  			    if @snp.allele_frequency.has_key?(snp_array[3][0].chr)
  			        @snp.allele_frequency[snp_array[3][0].chr] += 1
  		        else
  		          @snp.allele_frequency[snp_array[3][0].chr] = 1
  	            end
	          
  		        if @snp.allele_frequency.has_key?(snp_array[3][1].chr)
  		          @snp.allele_frequency[snp_array[3][1].chr] +=  1
				else
			      @snp.allele_frequency[snp_array[3][1].chr] = 1
			    end

  			    if @snp.genotype_frequency.has_key?(snp_array[3].rstrip)
  			      @snp.genotype_frequency[snp_array[3].rstrip] +=  1
  			    elsif @snp.genotype_frequency.has_key?(snp_array[3][1].chr+snp_array[3][0].chr)
  			      @snp.genotype_frequency[snp_array[3][1].chr+snp_array[3][0].chr] +=  1
  		        else
  		          @snp.genotype_frequency[snp_array[3].rstrip] = 1
  		        end
  		        @snp.save
  			    end
  		  end
  		end
		end
	end
end	
