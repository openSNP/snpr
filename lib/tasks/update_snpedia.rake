namespace :snpedia do
  desc "update snpedia"
  task :update => :environment do
    @snpedia_papers = SnpediaPaper.find(:all)
    @snpedia_papers.each do |sp|
      @snp = sp.snp
      @snp.snpedia_updated = Time.zone.now-3000000
      puts "updated time of snp"
      @snp.save
      sp.delete
      puts "deleted snpedia-entry"
    end
  end
end