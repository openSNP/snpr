require 'resque'

class Parsing
  @queue = :parse

  def self.perform(genotyp,temp_file)
    Rails.logger.level = 0
    Rails.logger = Logger.new("#{Rails.root}/log/parsing_#{Rails.env}.log")
    @genotype = Genotype.find_by_id(genotyp["genotype"]["id"].to_i)
    
    if @genotype.filetype != "other"
      
      genotype_file = File.open(temp_file, "r")
      log "Loading known Snps."
      known_snps = []
      #known_snps = Snp.all.index_by(&:name)
      new_snps = []
      new_user_snps = []

      log "Parsing file #{temp_file}"
      # open that file, go through each line
      genotype_file.each do |single_snp|
        next if single_snp[0] == "#"

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

        if snp_array.length == (4)
          # if we do not have the fitting SNP, make one and parse all paper-types for it
          
          #snp = known_snps[snp_array[0]]
          snp = Snp.find_by_name(snp_array[0])
          if snp.nil?  
            snp = Snp.new(:name => snp_array[0], :chromosome => snp_array[1], :position => snp_array[2], :ranking => 0)
            snp.default_frequencies
            new_snps << snp
          else
            known_snps << snp
          end

          # change allele-frequency and genotype-frequency for each SNP,
          # start with 1 if there is no frequency else just add
          if snp.allele_frequency.has_key?(snp_array[3][0].chr)
            snp.allele_frequency[snp_array[3][0].chr] += 1
          else
            snp.allele_frequency[snp_array[3][0].chr] = 1
          end

          if snp.allele_frequency.has_key?(snp_array[3][1].chr)
            snp.allele_frequency[snp_array[3][1].chr] +=  1
          else
            snp.allele_frequency[snp_array[3][1].chr] = 1
          end

          if snp.genotype_frequency.has_key?(snp_array[3].rstrip)
            snp.genotype_frequency[snp_array[3].rstrip] +=  1
          elsif snp.genotype_frequency.has_key?(snp_array[3][1].chr+snp_array[3][0].chr)
            snp.genotype_frequency[snp_array[3][1].chr+snp_array[3][0].chr] +=  1
          else
            snp.genotype_frequency[snp_array[3].rstrip] = 1
          end

          # make a new user_snp
          new_user_snps << [ @genotype.id, @genotype.user_id, snp.name, snp_array[3].rstrip ]
        else
          User.find_by_id(@genotype.user_id).toggle!(:has_sequence)
          break
        end
      end
      log "Importing new Snps"
      Snp.import new_snps
      log "Updating known Snps"
      if known_snps != []
        ActiveRecord::Base.transaction do
          known_snps.each(&:save)
        end
      end
      log "Importing new UserSnps"
      user_snp_columns = [ :genotype_id, :user_id, :snp_name, :local_genotype ]
      UserSnp.import user_snp_columns, new_user_snps, validate: false
      log "Done."
      puts "done with #{temp_file}"
      system("rm #{temp_file}")
    end
  end

  def self.log msg
    Rails.logger.info "#{DateTime.now}: #{msg}"
  end
end
