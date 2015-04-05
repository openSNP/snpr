require 'csv'
namespace :snps do
  desc 'Iterates over all SNPs, writes a CSV of annotation into public/'
  task dump: :environment do
    readme = File.new("#{Rails.root}/tmp/readme.txt", 'w')
    # get date
    readme.write("File created at: #{Time.now}\n")
    readme.write("PLOS data is licensed under Creative Commons Attribution.\nhttp://creativecommons.org/licenses/by/3.0/\nWebsite: http://api.plos.org\n")
    readme.write("Mendeley data is licensed under Create Commons Attribution.\nhttp://creativecommons.org/licenses/by/3.0/\nWebsite: http://apidocs.mendeley.com/\n")
    readme.write("SNPedia data is licensed under Creative Commons Attribution-Noncommercial-Share Alike 3.0 Unported.\nhttp://creativecommons.org/licenses/by-nc-sa/3.0/us/\nWebsite: http://snpedia.com/index.php/SNPedia:FAQ#Legal_.2F_Licensing\n")
    readme.write("Genome.gov data is in the public domain.\nWebsite: http://www.genome.gov/copyright.cfm\n")
    readme.write("Personal Genome Project is licensed under CC0.\nhttp://creativecommons.org/publicdomain/zero/1.0/\nWebsite: http://evidence.personalgenomes.org/about\n")
    readme.close
    # dump mendeley
    CSV.open("#{Rails.root}/tmp/mendeley.csv", 'wb') do |csv|
      csv << ['Name', 'Position', 'Chromosome', 'Year', 'First author', 'Title', 'DOI', 'Open Access status', 'Link']
      MendeleyPaper.find_each do |m|
        parental = m.snp
        position = parental.position.strip
        name = parental.name
        chrom = parental.chromosome
        first_author = m.first_author
        year = m.pub_year
        title = m.title
        doi = m.doi
        oa = m.open_access
        link = m.mendeley_url
        csv << [name, position, chrom, year, first_author, title, doi, oa, link]
      end
    end
    # dump snpedia
    CSV.open("#{Rails.root}/tmp/snpedia.csv", 'wb') do |csv|
      csv << %w(Name Position Chromosome Summary Link)
      SnpediaPaper.find_each do |sn|
        parental = sn.snp
        position = parental.position.strip
        name = parental.name
        chrom = parental.chromosome
        summary = sn.summary
        link = sn.url
        csv << [name, position, chrom, summary, link]
      end
    end
    # dump plos
    CSV.open("#{Rails.root}/tmp/plos.csv", 'wb') do |csv|
      csv << ['Name', 'Position', 'Chromosome', 'Year', 'First author', 'Title', 'DOI']
      PlosPaper.find_each do |sp|
        parental = sp.snp
        position = parental.position.strip
        name = parental.name
        chrom = parental.chromosome
        first_author = sp.first_author
        title = sp.title
        doi = sp.doi
        year = sp.pub_date
        csv << [name, position, chrom, year, first_author, title, doi]
      end
    end
    # dump pgp
    CSV.open("#{Rails.root}/tmp/pgp.csv", 'wb') do |csv|
      csv << ['Name', 'Position', 'Chromosome', 'Gene', 'Qualified Impact', 'Inheritance', 'Summary', 'Trait']
      PgpAnnotation.find_each do |spg|
        parental = spg.snp
        position = parental.position.strip
        name = parental.name
        chrom = parental.chromosome
        gene = spg.gene
        impact = spg.qualified_impact
        inheritance = spg.inheritance
        summ = spg.summary
        trait = spg.trait
        csv << [name, position, chrom, gene, impact, inheritance, summ, trait]
      end
    end
    # dump genome_gov
    CSV.open("#{Rails.root}/tmp/genome_gov.csv", 'wb') do |csv|
      csv << ['Name', 'Position', 'Chromosome', 'First Author', 'Title', 'Pubmed link', 'Year', 'Journal', 'Trait', 'p-value', 'p-value description', 'Confidence Interval']
      GenomeGovPaper.find_each do |gg|
        parental = gg.snp
        position = parental.position.strip
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
        csv << [name, position, chrom, author, title, pubmed, year, journal, trait, pvalue, pvalue_description, conf]
      end
    end

    # get rid of old Zip
    if File.exist? "#{Rails.root}/public/data/annotation.zip"
      File.delete("#{Rails.root}/public/data/annotation.zip")
    end

    # now zip the CSVs and put the zip into /public
    Zip::ZipFile.open("#{Rails.root}/public/data/annotation.zip", Zip::ZipFile::CREATE) do |zipfile|
      zipfile.add('genome_gov.csv', "#{Rails.root}/tmp/genome_gov.csv")
      zipfile.add('readme.txt', "#{Rails.root}/tmp/readme.txt")
      zipfile.add('pgp.csv', "#{Rails.root}/tmp/pgp.csv")
      zipfile.add('mendeley.csv', "#{Rails.root}/tmp/mendeley.csv")
      zipfile.add('plos.csv', "#{Rails.root}/tmp/plos.csv")
      zipfile.add('snpedia.csv', "#{Rails.root}/tmp/snpedia.csv")
    end
    FileUtils.chmod(0665, "#{Rails.root}/public/data/annotation.zip")
    # delete the CSVs?
  end
end
