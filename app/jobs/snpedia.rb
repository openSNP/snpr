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
            puts "SNPedia: Got page\n"
            url = "http://www.snpedia.com/index.php/" + p.to_s
            if SnpediaPaper.find_all_by_url(url)  == []
               puts "-> Parsing new site\n"
               toparse = mw.get(p)
               summary = toparse.split("|")[4].delete("}\n")
               summary = summary[8,summary.length]
               @snpedia_link = SnpediaPaper.new(:url => url, :snp_id => @snp.id, :summary => summary).save
               @snp.ranking = @snp.mendeley_paper.count + 2*@snp.plos_paper.count + 5*@snp.snpedia_paper.count
               @snp.save
            else
               puts "-> old site"
            end
         else
            puts "No pages"
         end
      end
      print "sleep for 5 seconds\n"
      sleep(5)
   end
end
