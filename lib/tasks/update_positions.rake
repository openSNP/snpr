namespace :snps do
  desc "updates all positions of SNPs according to /var/www/all_positions.txt"
  task :update => :environment do
        fh = open("/var/www/all_positions.txt")
        # parse out positions first
        pos_dict = Hash.new # key: SNP-name -> value [chrX, position]
        fh.each_line do |l|
            ll = l.split("\t")
            name = ll[0]
            chr = ll[1]
            pos = ll[2]
            pos_dict[name] = [chr, pos]
        end
        # now iterate over SNPs and fix
        Snp.find_each do |s|
            new = pos_dict[s.name]
            if new != nil
                new_pos = new[1]
                new_chr = new[0].gsub("chr","")
                s.position = new_pos
                s.chromosome = new_chr
                s.save
            end
        end
  end
end
