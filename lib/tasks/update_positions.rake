# get VCF first from ftp://ftp.ncbi.nlm.nih.gov/snp/organisms/human_9606_b141_GRCh38/VCF/All.vcf.gz (about 1.3GB) and gunzip
# put into /var/www/all_positions.txt

namespace :snps do
  desc "updates all positions of SNPs according to /var/www/all_positions.txt"
  task :update_positions => :environment do
        fh = open("/var/www/all_positions.txt")
        fh.each_line do |l|
            next if l.start_with? '#'
            ll = l.split("\t")
            name = ll[2]
            s = Snp.find_by_name(name)
            next if s.nil?
            pos = ll[1]
            s.position = pos
            s.save
        end
  end
end
