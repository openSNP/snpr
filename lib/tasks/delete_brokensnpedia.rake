# delete broken snpedia_papers

namespace :snpedia_papers do
  desc "delete broken snpedia-links"
  task :delete => :environment do
      Snp.all.each do |s|
        if s.snpedia_paper.length > 3
            s.update_attributes(:snpedia_updated => "2010-05-04")
            # actual deletion of the old entries is handled by the resque-task
            Resque.enqueue(Snpedia, s.id)
        end
      end
  end
end
