require 'resque'
require 'net/http'
require 'rexml/document'
require 'media_wiki'

class Snpedia
   @queue = :snpedia

   def self.perform(snp)
      @snp = Snp.find_by_id(snp["snp"]["id"].to_i)
      if @snp.snpedia_updated + 2678400 < Time.zone.now
        mw = MediaWiki::Gateway.new("http://www.snpedia.com/api.php")
        # return an array of page-titles
        pages = mw.list(@snp.name)

        pages.each do |p|
           if p.index("(") != nil
              puts "snpedia: Got page\n"
              url = "http://www.snpedia.com/index.php/" + p.to_s
              if SnpediaPaper.find_all_by_url(url)  == []
                 puts "-> Parsing new site\n"
                 toparse = mw.get(p)
                 summary = toparse.split("|")[4].delete("}\n")
                 summary = summary[8,summary.length]
                 @snpedia_link = SnpediaPaper.new(:url => url, :snp_id => @snp.id, :summary => summary)
  			   @snpedia_link.save
                 @snp.ranking = @snp.mendeley_paper.count + 2*@snp.plos_paper.count + 5*@snp.snpedia_paper.count
              else
                 puts "-> old site\n"
              end
           else
              puts "snpedia: No pages\n"
           end
        end
        @snp.snpedia_updated = Time.zone.now
        @snp.save
        print "snpedia: sleep for 5 seconds\n"
        sleep(5)
      else
        print "snpedia: time threshold not met\n"
      end
   end
end
