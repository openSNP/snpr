def check_to_destroy(type)
  set_to_destroy = Set.new []
  type.find_each do |m|
    parental = m.snp
    if parental == nil
      set_to_destroy.add(m)
      next
    end
    # check if name of parental snp is a pesky vg-SNP
    if parental.name.start_with? "vg"
      set_to_destroy.add(m)
    end
  end 
  set_to_destroy
end

def destroy(set, type)
  set.each do |s|
    if s.parental != nil and s.parental.name.start_with? "vg"
      # has to be a vg-SNP, we don't want annotation for these right now as they are mostly bogus
      s.parental.update_attributes(:ranking => 0)
    end
    # delete
    puts "Want to destroy: #{s.inspect}"
    type.destroy(s)
  end
end

namespace :snps do
  desc "Iterates over all annotations, deletes a) ones without SNP and b) annotations for SNPs starting in 'vg' (also sets vg-SNPs scores to 0)"
  task :clean_annotation => :environment do
    require 'set'
    # need to store annotations to destroy first, iterating over stuff
    # while destroying it only makes problems
    ms_to_destroy = check_to_destroy(MendeleyPaper)
    sn_to_destroy = check_to_destroy(SnpediaPaper)
    sp_to_destroy = check_to_destroy(PlosPaper)
    spg_to_destroy = check_to_destroy(PgpAnnotation)
    gg_to_destroy = check_to_destroy(GenomeGovPaper)
    destroy(ms_to_destroy, MendeleyPaper)
    destroy(sn_to_destroy, SnpediaPaper)
    destroy(sp_to_destroy, PlosPaper)
    destroy(spg_to_destroy, PgpAnnotation)
    destroy(gg_to_destroy, GenomeGovPaper)
  end
end
