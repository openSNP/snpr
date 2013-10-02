xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
	xml.channel do
		xml.title "Genotyping-files for "+@phenotype.characteristic
		xml.description "A RSS-feed which contains the newest genotyping files of users who have entered their variation for "+@phenotype.characteristic
		xml.link phenotype_url(@phenotype)

		for genotype in @genotypes
			xml.item do
               xml.title User.find_by_id(genotype.user_id).name + "'s Genotype"
               xml.description "The user  "+genotype.user.name+" has uploaded a picture for the phenotype "+@phenotype.characteristic+": "+image_tag("http://opensnp.org"+genotype.user.user_picture_phenotypes.find_by_picture_phenotype_id(@phenotype).phenotype_picture.url(:medium))+" "+link_to("Download",'/data/' + genotype.fs_filename)
               xml.picture genotype.user.user_picture_phenotypes.find_by_picture_phenotype_id(@phenotype).phenotype_picture.url(:maximum)
               xml.dlink 'http://opensnp.org/data/' + genotype.fs_filename
			   xml.pubDate genotype.created_at.to_s(:rfc822)
			   xml.link genotype_url(genotype)
			   xml.guid genotype_url(genotype)
			end
		end
	end
end
