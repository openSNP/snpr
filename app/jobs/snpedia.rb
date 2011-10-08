require 'resque'
require 'net/http'
require 'rexml/document'
require 'media_wiki'

class Snpedia
   include Resque::Plugins::UniqueJob
   @queue = :snpedia

   def self.perform(snp_id)
      @snp = Snp.find(snp_id)
      if @snp.snpedia_updated < 31.days.ago
        mw = MediaWiki::Gateway.new("http://www.snpedia.com/api.php")
        # return an array of page-titles
        pages = mw.list(@snp.name + "(")
        if pages != nil
          pages.each do |p|
            if p.index("(") != nil
              puts "snpedia: Got page\n"
              url = "http://www.snpedia.com/index.php/" + p.to_s
              if SnpediaPaper.find_all_by_url(url)  == []
                puts "-> Parsing new site\n"
                toparse = mw.get(p)
                summary = toparse[toparse.index("summary=")+8..toparse.length()-4]
                @snpedia_link = SnpediaPaper.new(:url => url, :snp_id => @snp.id, :summary => summary)
                @snpedia_link.save
								if @snp.mendeley_paper.count == nil:
									mendeley_count = 0
								else
									mendeley_count = @snp.mendeley_paper.count
								end
								if @snp.plos_paper.count == nil:
									plos_count = 0
								else
									plos_count = @snp.plos_paper.count
								end
								if @snp.snpedia_paper.count == nil:
									snpedia_count = 0
								else
									snpedia_count = @snp.snpedia_paper.count

                @snp.ranking = mendeley_count + 2*plos_count + 5*snpedia_count
              else
                puts "-> old site\n"
              end
            else
              puts "snpedia: No pages\n"
            end
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
