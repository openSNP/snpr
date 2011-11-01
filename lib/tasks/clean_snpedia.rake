namespace :snpedia do
	desc "kick out those nasty extra-crap things"
	task :clean => :environment do
		SnpediaPaper.find(:all).each do |paper|
			if paper.summary.index("}}") != nil
				puts "OLD"
				puts paper.summary
				paper.update_attributes(:summary => paper.summary[0...paper.summary.index("}}")-1])
				puts "NEW"
				puts paper.summary
			end
		end
	end
end
