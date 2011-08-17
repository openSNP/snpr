require 'resque' 

class Parsing
	@queue = :parse

	def self.perform(genotyp)
	  @genotype = Genotype.find_by_id(genotyp["genotype"]["id"].to_i)
	  if @genotype.filetype != "other"
  		genotype_file = File.open(::Rails.root.to_s+"/public/data/"+ @genotype.fs_filename, "r")
  		new_snps = genotype_file.readlines
  		new_snps.each do |single_snp|
  		  puts single_snp[0]
  		  puts single_snp[0].chr
  			if single_snp[0].chr != "#"
			  
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
  				    if Snp.find_by_name(snp_array[0]) == nil
  				      @snp = Snp.new()
  				      @snp.name = snp_array[0]
  				      @snp.chromosome = snp_array[1]
  				      @snp.position = snp_array[2]
  				      @snp.save
  				    else 
  				      @snp = Snp.find_by_name(snp_array[0])
  			      end
  			      @user_snp = UserSnp.new()
  			      @user_snp.genotype_id = @genotype.id
  			      @user_snp.user_id = @genotype.user_id
  			      @user_snp.snp_id = @snp.id
  			      @user_snp.local_genotype = snp_array[3].rstrip
  			      @user_snp.save
			      
  			      if @snp.allele_frequency.has_key?(snp_array[3][0].chr)
  			        @snp.allele_frequency[snp_array[3][0].chr] += 1
  		        else
  		          @snp.allele_frequency[snp_array[3][0].chr] = 1
  	          end
	          
  		        if @snp.allele_frequency.has_key?(snp_array[3][1].chr)
  		          @snp.allele_frequency[snp_array[3][1].chr] += 1
  	          else
  	            @snp.allele_frequency[snp_array[3][1].chr] = 1
              end

  			      if @snp.genotype_frequency.has_key?(snp_array[3].rstrip)
  			        @snp.genotype_frequency[snp_array[3].rstrip] += 1
  			      elsif @snp.genotype_frequency.has_key?(snp_array[3][1].chr+snp_array[3][0].chr)
  			        @snp.genotype_frequency[snp_array[3][1].chr+snp_array[3][0].chr] += 1
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
