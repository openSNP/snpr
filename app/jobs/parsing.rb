require 'resque'

class Parsing
  @queue = :parse

  def self.perform(genotype_id, temp_file)
    Rails.logger.level = 0
    Rails.logger = Logger.new("#{Rails.root}/log/parsing_#{Rails.env}.log")
    genotype_id = genotype_id["genotype"]["id"].to_i if genotype_id.is_a?(Hash)
    @genotype = Genotype.find(genotype_id)
    
    if @genotype.filetype != "other"

      genotype_file = File.open(temp_file, "r")
      log "Loading known Snps."
      known_snps = {}
      Snp.find_each do |s| known_snps[s.name] = true end
      
      known_user_snps = {}  
      UserSnp.where("user_id" => @genotype.user_id).find_each do |us| known_user_snps[us.snp_name] = true end
        
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
            next
          end
          
        elsif @genotype.filetype == "ftdna-illumina"
          temp_array = single_snp.split("\",\"")
          if temp_array[0].index("RSID") == nil
            if temp_array[0] != nil and temp_array[1] != nil and temp_array[2] != nil and temp_array[3] != nil
            snp_array = [temp_array[0].gsub("\"",""),temp_array[1].gsub("\"",""),temp_array[2].gsub("\"",""),temp_array[3].gsub("\"","").rstrip]
            else
              UserMailer.parsing_error(@genotype.user_id).deliver
              break
            end
          else
            next
          end
          
        elsif @genotype.filetype == "23andme-exome-vcf"
          temp_array = single_snp.split("\t")
          @format_array = temp_array[-2].split(":")
          @format_array.each_with_index do |element,index|
            if element == "GT"
              @genotype_position = index
            end
          end
          @genotype_non_parsed = temp_array[-1].split(":")[@genotype_position].split("/")
          @genotype_parsed = ""
          @genotype_non_parsed.each do |allele|
            if allele == "0"
              @genotype_parsed = @genotype_parsed + temp_array[3]
            elsif allele == "1"
              @genotype_parsed = @genotype_parsed + temp_array[4]
            end
          end
          snp_array = [temp_array[2].downcase,temp_array[0],temp_array[1],@genotype_parsed.upcase]
          
          snp = known_snps[snp_array[0].downcase]
          if snp.nil?
            next
          end    
        end

        if snp_array[0] != nil and snp_array[1] != nil and snp_array[2] != nil and snp_array[3] != nil
          # if we do not have the fitting SNP, make one and parse all paper-types for it
          
          snp = known_snps[snp_array[0].downcase]
          if snp.nil?  
            snp = Snp.new(:name => snp_array[0].downcase, :chromosome => snp_array[1], :position => snp_array[2], :ranking => 0)
            snp.default_frequencies
            new_snps << snp
          end
          
          new_user_snp = known_user_snps[snp_array[0].downcase]
          if new_user_snp.nil?
            new_user_snps << [ @genotype.id, @genotype.user_id, snp_array[0].downcase, snp_array[3].rstrip ]
          else
            log "already known user-snp"
          end
        else
          UserMailer.parsing_error(@genotype.user_id).deliver
          break
        end
      end
      log "Importing new Snps"
      Snp.import new_snps

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
