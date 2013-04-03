require 'net/http'
require 'rexml/document'
require 'media_wiki'

class Snpedia
   include Sidekiq::Worker
   sidekiq_options :queue => :snpedia, :retry => 5, :unique => true

   def perform(snp_id)
      @snp = Snp.find(snp_id)
      # get the marshalled array
      namearray = []
      File.open("#{Rails.root}/marshalled_snpedia_array", "r") do |file|
         namearray = Marshal.load(file)
      end

      if !namearray.include?(@snp.name)
         puts @snp.name + " not included in the array"
      else
         if @snp.snpedia_updated < 31.days.ago
            mw = MediaWiki::Gateway.new("http://www.snpedia.com/api.php")
            # return an array of page-titles
            pages = mw.list(@snp.name + "(")
            if pages != nil
               pages.each do |p|
                  if p.index("(") != nil
                     puts "snpedia: Got page\n"
                     url = "http://www.snpedia.com/index.php/" + p.to_s
                     # revision returns an int which grows with changes
                     rev_id = mw.revision(p).to_i
                     s = SnpediaPaper.find_by_url(url)
                     if SnpediaPaper.find_all_by_url(url) == [] or (s != nil and s.revision != rev_id)
                        puts "-> Parsing new or changed site\n"
                        puts "url: " + url
                        # delete the old entries
                        SnpediaPaper.find_all_by_url(url).each do |s|
                            SnpediaPaper.delete(s)
                        end

                        toparse = mw.get(p)
                        if toparse.to_s.include? "#REDIRECT"
                           # Don't include redirect-descriptions 
                           puts "#{p} is a redirect"
                           next # jump to next SNPedia-entry
                        elsif not toparse.include? "summary="
                           puts "#{p} is empty"
                           # Handle empty summaries
                           summary = "No summary provided."
                        else
                           puts "#{p} has stuff"
                           summary = toparse[toparse.index("summary=")+8..toparse.length()-4]
                           if summary.index("}}") != nil
                              summary = summary[0...summary.index("}}")-1]
                           end
                        end
                        @snpedia_link = SnpediaPaper.new(:url => url, :snp_id => @snp.id, :summary => summary, :revision => rev_id)
                        @snpedia_link.save
                        if @snp.mendeley_paper.count == nil
                           mendeley_count = 0
                        else
                           mendeley_count = @snp.mendeley_paper.count
                        end
                        if @snp.plos_paper.count == nil
                           plos_count = 0
                        else
                           plos_count = @snp.plos_paper.count
                        end
                        if @snp.snpedia_paper.count == nil
                           snpedia_count = 0
                        else
                           snpedia_count = @snp.snpedia_paper.count
                        end

                        @snp.ranking = @snp.mendeley_paper.count + 2*@snp.plos_paper.count + 5*@snp.snpedia_paper.count + 2*@snp.genome_gov_paper.count + 2*@snp.pgp_annotation.count
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
end
