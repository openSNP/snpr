xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
	xml.channel do
		xml.title "Genotyping-files for "+@phenotype.characteristic
		xml.description "A RSS-feed which contains the newest genotyping files of users who have entered their variation for "+@phenotype.characteristic
		xml.link phenotype_url(@phenotype)

		for genotype in @genotypes
			xml.item do
               xml.title User.find_by_id(genotype.user_id).name + "'s Genotype"
               xml.description "The variation of "+genotype.user.name+" for the phenotype "+@phenotype.characteristic+" is "+genotype.user.user_phenotypes.find_by_phenotype_id(@phenotype).variation+" "+link_to("Download",'/data/' + genotype.fs_filename)
               xml.variation genotype.user.user_phenotypes.find_by_phenotype_id(@phenotype).variation
               xml.dlink 'http://opensnp.org/data/' + genotype.fs_filename
			   xml.pubDate genotype.created_at.to_s(:rfc822)
			   xml.link genotype_url(genotype)
			   xml.guid genotype_url(genotype)
			end
		end
	end
end
