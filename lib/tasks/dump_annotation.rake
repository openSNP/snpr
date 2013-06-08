namespace :snps do
  desc "Iterates over all SNPs, writes a CSV of annotation into public/"
  task :dump => :environment do
    f = File.new("#{Rails.root}/public/annotation.csv", "w")
    # get date
    f.write("File created at: #{Time.now}\n")
    # dump header
    # dump mendeley
    f.write("Mendeley\n")
    f.write("SNP\tPosition\tChromosome\tYear\tFirst Author\tTitle\tDOI\tOpen Access\tLink\n")
    MendeleyPaper.find_each do |m|
      parental = m.snp
      position = parental.position
      name = parental.name
      chrom = parental.chromosome
      first_author = m.first_author
      year = m.pub_year
      title = m.title
      doi = m.doi
      oa = m.open_access
      link = m.mendeley_url
      f.write("#{name}\t#{position}\t#{chrom}\t#{year}\t#{first_author}\t#{title}\t#{doi}\t#{oa}\t#{link}\n")
    end 
    # dump snpedia
    f.write("Snpedia\n")
    f.write("SNP\tPosition\tChromosome\tSummary\tLink\n")
    SnpediaPaper.find_each do |sn|
      parental = sn.snp
      position = parental.position
      name = parental.name
      chrom = parental.chromosome
      summary = sn.summary
      link = sn.url
      f.write("#{name}\t#{position}\t#{chrom}\t#{summary}\t#{link}\n")
    end
    # dump plos
    f.write("PLOS\n")
    f.write("SNP\tPosition\tChromosome\tFirst author\tTitle\tDOI\tYear\n")
    PlosPaper.find_each do |sp|
      parental = sp.snp
      position = parental.position
      name = parental.name
      chrom = parental.chromosome
      first_author = sp.first_author
      title = sp.title
      doi = sp.doi
      year = sp.pub_date
      f.write("#{name}\t#{position}\t#{chrom}\t#{year}\t#{first_author}\t#{title}\t#{doi}\n")
    end
    # dump pgp
    f.write("PGP\n")
    #nteger, gene: text, qualified_impact: text, inheritance: text, summary: text, trait: text, 
    f.write("SNP\tPosition\tChromosome\tGene\tQualified Impact\tInheritance\tSummary\tTrait\n")
    PgpAnnotation.find_each do |spg|
      parental = sp.snp
      position = parental.position
      name = parental.name
      chrom = parental.chromosome
      gene = spg.gene
      impact = spg.qualified_impact
      inheritance = spg.inheritance
      summ = spg.summary
      trait = spg.trait
      f.write("#{name}\t#{position}\t#{chrom}\t#{gene}\t#{impact}\t#{inheritance}\t#{summ}\t#{trait}\n")
    end
    # dump genome_gov
    f.write("Genome.gov\n")
    f.write("SNP\tPosition\tChromosome\tFirst author\tTitle\tPubmed-link\tYear\tJournal\tTrait\tp-value\tp-value description\tConfidence Interval\n")
    GenomeGovPaper.find_each do |gg|
      parental = gg.snp
      position = parental.position
      name = parental.name
      chrom = parental.chromosome
      author = gg.first_author
      title = gg.title
      pubmed = gg.pubmed_link
      journal = gg.journal
      year = gg.pub_date
      trait = gg.trait
      pvalue = gg.pvalue
      pvalue_description = gg.pvalue_description
      conf = gg.confidence_interval
      f.write("#{name}\t#{position}\t#{chrom}\t#{first_author}\t#{title}\t#{pubmed}\t#{year}\t#{journal}\t#{trait}\t#{pvalue}\t#{pvalue_description}\t#{conf}\n")
    end
  end
end
