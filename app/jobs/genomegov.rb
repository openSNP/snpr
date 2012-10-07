require 'resque'
require 'open-uri'

class GenomeGov
  include Resque::Plugins::UniqueJob
  @queue = :genomegov
  
  def self.perform()
    known_snps = {}
    Snp.find_each do |s| known_snps[s.name] = true end
      
    genome_file  = open('http://www.genome.gov/admin/gwascatalog.txt') {|f| f.readlines }
    
    genome_file.each do |genome_entry|
      genome_array = genome_entry.split("\t")
      snp_id = genome_array[21]
      if snp_id == nil
        snp_id = "NA"
      end
      if known_snps.has_key?(snp_id.downcase)
        puts "yes"
        confidence_interval = genome_array[31]
        pvalue_description = genome_array[29]
        pvalue_string = genome_array[27]
        first_author = genome_array[2]
        pub_date = genome_array[3]
        puts pub_date
        journal = genome_array[4]
        pubmed_link = genome_array[5]
        title = genome_array[6]
        trait = genome_array[7]
        begin
          pvalue = pvalue_string.to_f
        rescue
          pvalue = 1
        end
        
        puts pvalue
        
        if pvalue < 1e-8
          snp = Snp.find_by_name(snp_id)
          paper = snp.genome_gov_paper.find_by_title_and_pubmed_link(title,pubmed_link)
          if paper == nil
            paper = GenomeGovPaper.new()
            paper.snp_id = snp.id
          end
          # enter all the information here and update if needed, just to keep everything fresh 
          paper.confidence_interval = confidence_interval
          paper.pvalue_description = pvalue_description
          paper.pvalue = pvalue 
          paper.pubmed_link = pubmed_link
          paper.first_author = first_author
          paper.pub_date = pub_date
          paper.title = title
          paper.journal = journal
          paper.trait = trait
          paper.save
          puts paper
        end
      end
    end
  end
end

      
           