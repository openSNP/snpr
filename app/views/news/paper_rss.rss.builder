xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
	xml.channel do
		xml.title "Latest papers on SNPs which are listed by openSNP"
		xml.description "This feed includes the latest publications which can be found at Mendeley and the Public Library of Science about SNPs which are in the openSNP database."
		xml.link "http://opensnp.org"

		for paper in @newest_paper
			xml.item do
               for snp in paper.snps do
                xml.title snp.name + ": "+ paper.title
                if paper.class == MendeleyPaper
                  xml.description "The paper \""+paper.title+"\" is about SNP "+snp.name+" and was published in "+paper.pub_year.to_s+ " by "+paper.first_author+" et al. and so far "+paper.reader.to_s+" people have read it on Mendeley."
                  xml.link paper.mendeley_url
                  xml.guid "mendeley_"+paper.id.to_s
                elsif paper.class == PlosPaper
                  xml.description "The paper \""+paper.title+"\" is about SNP "+snp.name+" and was published in one of the PLoS journals in "+paper.pub_date.to_s[6,4]+" by "+paper.first_author+ " et al. and so far "+paper.reader.to_s+" people have read it there."
                  xml.link "https://doi.org/"+paper.doi
                  xml.guid "plos_"+paper.id.to_s 
                end
               end
			   xml.pubDate paper.created_at.to_s(:rfc822)
			end
		end
	end
end
