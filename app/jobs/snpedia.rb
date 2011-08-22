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
	puts pages
	
	pages.each do |p|
		url = "http://www.snpedia.com/index.php/" + p.to_s
		if SnpediaPaper.find_all_by_url(url)  == []
			@snpedia_link = SnpediaPaper.new()
			@snpedia_link.url = url
			@snpedia_link.snp_id = @snp.id
			@snpedia_link.save
		end
	end
	print "sleep for 5 seconds"
	sleep(5)
  end
end
