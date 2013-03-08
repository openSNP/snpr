require 'open-uri'
require 'iconv'

class GenomeGov
  include Sidekiq::Worker
  sidekiq_options :queue => :genomegov
  
  def perform()
    known_snps = {}
    Snp.find_each do |s| known_snps[s.name] = true end
      
    genome_file  = open('http://www.genome.gov/admin/gwascatalog.txt') {|f| f.readlines }
    
    genome_file.each do |genome_entry|
      genome_array = Iconv.conv("UTF-8","windows-1252",genome_entry).split("\t")
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
          puts paper
          if paper == nil
            paper = GenomeGovPaper.new()
            paper.snp_id = snp.id
          end
          # enter all the information here and update if needed, just to keep everything fresh 
          paper.confidence_interval = confidence_interval
          paper.pvalue_description = pvalue_description
          paper.pvalue = pvalue 
          if pvalue < 1e-100
            pvalue = 1e-100
          end
          paper.pubmed_link = pubmed_link
          paper.first_author = first_author
          paper.pub_date = pub_date
          paper.title = title
          paper.journal = journal
          paper.trait = trait
          paper.save
          puts paper
          snp.ranking = snp.mendeley_paper.count + 2*snp.plos_paper.count + 5*snp.snpedia_paper.count + 2*snp.genome_gov_paper.count + 2*snp.pgp_annotation.count
          snp.save
        end
      end
    end
    puts "done!"
  end
end

      
           
