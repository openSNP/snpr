namespace :custom do
  desc 'Adding custom data to Phenotype SNP table'
  task :snp_link => :environment do
    @snps = Snp.find_by_name('rs4475691')
    @phenotype = Phenotype.create :characteristic => 'Brown'
    PhenotypeSnp.create :snp => @snps, :phenotype => @phenotype, :score => 5

    @snps = Snp.find_by_name('rs3890745')
    @phenotype = Phenotype.create :characteristic => 'Arthritis'
    PhenotypeSnp.create :snp => @snps, :phenotype => @phenotype, :score => 7

    @snps = Snp.find_by_name('rs2651899')
    @phenotype = Phenotype.create :characteristic => 'Migrain'
    PhenotypeSnp.create :snp => @snps, :phenotype => @phenotype, :score => 6
  end
end
