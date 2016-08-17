
require 'open-uri'

class PgpAnnotationjob
  include Sidekiq::Worker
  sidekiq_options :queue => :pgp, :retry => 5, :unique => true

  def perform()
    puts "Running PgpAnnotationJob\n"
    known_snps = {}
    Snp.find_each do |s| known_snps[s.name] = true end

    pgp_file  = open('http://evidence.personalgenomes.org/download/latest/flat/latest-flat.tsv') {|f| f.readlines }

    puts "got pgp file"

    pgp_file.each do |pgp_entry|
        puts pgp_entry
      pgp_entry_array = pgp_entry.strip().split("\t")
      snp_id = pgp_entry_array[7]
      if snp_id == nil
        snp_id = "NA"
        puts "snp not found"
      end
      if known_snps.has_key?(snp_id.downcase)
        puts "yes"
        gene = pgp_entry_array[0]
        qualified_impact = pgp_entry_array[4]
        inheritance = pgp_entry_array[5]
        summary = pgp_entry_array[-1]
        trait = pgp_entry_array[37]

        snp = Snp.find_by_name(snp_id)
        annotation = PgpAnnotation.find_by_snp_id(snp.id)
        if annotation == nil
          annotation = PgpAnnotation.new()
          annotation.snp_id = snp.id
        end
        # enter all the information here and update if needed, just to keep everything fresh
        annotation.gene = gene
        annotation.qualified_impact = qualified_impact
        annotation.inheritance = inheritance
        annotation.summary = summary
        annotation.trait = trait
        snp.ranking = snp.mendeley_paper.count + 2*snp.plos_paper.count + 5*snp.snpedia_paper.count + 2*snp.genome_gov_paper.count + 2*snp.pgp_annotations.count
        if qualified_impact != "Insufficiently evaluated not reviewed" and qualified_impact != "Insufficiently evaluated pharmacogenetic"
	  annotation.save
          snp.save()
        end
      end
    end
  end
end
