xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
	xml.channel do
		xml.title "openSNP Genotypes"
		xml.description "An RSS feed containing the newest genotyping files uploaded by openSNP users"
		xml.link root_url + "genotypes"

		for genotype in @genotypes
			xml.item do
               xml.title User.find_by_id(genotype.user_id).name + "'s Genotype"
			   xml.pubDate genotype.created_at.to_s(:rfc822)
			   xml.link genotype_url(genotype)
			   xml.guid genotype_url(genotype)
			end
		end
	end
end
