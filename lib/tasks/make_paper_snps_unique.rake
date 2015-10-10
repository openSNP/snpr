namespace :papers do
  task :make_linked_snps_unique => :environment do
    %w(MendeleyPaper SnpediaPaper PlosPaper).each do |source|
      source.constantize.find_each do |s|
        s.update(snps: s.snps.uniq)
      end
    end
  end
end
