require 'resque'

class Parsing
  @queue = :parse

  def self.perform(genotyp)
    Rails.logger.level = 0
    Rails.logger = Logger.new("#{Rails.root}/log/parsing_#{Rails.env}.log")
    @genotype = Genotype.find_by_id(genotyp["genotype"]["id"].to_i)
    filename = "#{Rails.root}/public/data/#{@genotype.fs_filename}"
    # do we have a normal filetype?
    if @genotype.filetype != "other"
      genotype_file = File.open(filename, "r")
      known_snps = Snp.all.index_by(&:name)
      new_snps = []
      new_user_snps = []

      Rails.logger.info "Parsing file #{filename}"
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
          snp = known_snps[snp_array[0]]
          if snp.nil?
            snp = Snp.new(:name => snp_array[0], :chromosome => snp_array[1], :position => snp_array[2], :ranking => 0)
            snp.default_frequencies
            new_snps << snp
            # TODO: put these in a rake task to be called by a cron job or so...
            Resque.enqueue(Plos,     snp)
            Resque.enqueue(Mendeley, snp)
            Resque.enqueue(Snpedia,  snp)
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
        end
      end
      Rails.logger.info "Importing new Snps"
      Snp.import new_snps
      Rails.logger.info "Updating known Snps"
      ActiveRecord::Base.transaction do
        known_snps.each_value(&:save)
      end
      Rails.logger.info "Importing new UserSnps"
      user_snp_columns = [ :genotype_id, :user_id, :snp_name, :local_genotype ]
      UserSnp.import user_snp_columns, new_user_snps, validate: false
      Rails.logger.info "Done."
    end
  end
end
