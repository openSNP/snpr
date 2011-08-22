require 'resque'
require 'net/http'
require 'rexml/document'
require 'media_wiki'

class Snpedia
  @queue = :snpedia
  
  def self.perform(snp)
    @snp = Snp.find_by_id(snp["snp"]["id"].to_i)
    mw = MediaWiki::Gateway.new("http://www.snpedia.com/api.php")
	# return an array of page-titles
	pages = mw.list(@snp.name)
	
	pages.each do |p|
		if p.index("(") != nil
			puts "Parsing SNPedia"
			url = "http://www.snpedia.com/index.php/" + p.to_s
			if SnpediaPaper.find_all_by_url(url)  == []
				puts "Parsing single site"
				toparse = mw.get[p]
				summary = toparse.split("|")[4].delete("}\n")
				summary = summary[8,summary.length]
				@snpedia_link = SnpediaPaper.new()
				@snpedia_link.url = url
				@snpedia_link.snp_id = @snp.id
				@snpedia_link.summary = summary
				@snpedia_link.save
			end
		end
	end
	print "sleep for 5 seconds"
	sleep(5)
  end
end
