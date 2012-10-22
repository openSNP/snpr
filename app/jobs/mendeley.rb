require "resque"
require "rubygems"
require "net/http"
require "json"

class Mendeley
   include Resque::Plugins::UniqueJob
   @queue = :mendeley

   def self.perform(snp_id)
      @snp = Snp.find(snp_id)
      if @snp.mendeley_updated < 31.days.ago
        key_handle = File.open(::Rails.root.to_s+"/key_mendeley.txt")
        api_key = key_handle.readline.rstrip

        url = "http://api.mendeley.com/oapi/documents/search/"+@snp.name+"/?consumer_key="+api_key

        begin
           resp = Net::HTTP.get_response(URI.parse(url))
        rescue
           retry
        end

        data = resp.body
        result = JSON.parse(data)

        if result["error"] != 0
           print "Mendeley API seems to be down.\n"
           print "Error is:\n"
           print result["error"] 
           print "\n"
           @snp.mendeley_updated = Time.zone.now
           @snp.save
           sleep(1)
        elsif result["total_results"] != 0
           print "mendeley: Got papers\n"

           result["documents"].each do |document|
              mendeley_url = document["mendeley_url"]
              uuid = document["uuid"].to_s
              begin
                first_author = document["authors"][0]["forename"]+" "+document["authors"][0]["surname"]
              rescue
                print "Something wrong in " + document["authors"]
                first_author = "Unknown"
              end
              title = document["title"]
              pub_year = document["year"]
              doi = document["doi"]

              if MendeleyPaper.find_all_by_uuid(uuid) == []
                 print "-> paper is new\n"
                 @mendeley_paper = MendeleyPaper.new(:mendeley_url => mendeley_url, :first_author => first_author, :pub_year => pub_year, :title => title, :uuid => uuid, :snp_id => @snp.id)
                 if doi != []
                    @mendeley_paper.doi = doi
                 end

                 @mendeley_paper.save
                 @snp.ranking = @snp.mendeley_paper.count + 2*@snp.plos_paper.count + 5*@snp.snpedia_paper.count
  
                 print "-> Written paper\n"
              else
                 print "-> paper is old\n"
                 @mendeley_paper = MendeleyPaper.find_by_uuid(uuid)
              end
              Resque.enqueue(MendeleyDetails,@mendeley_paper)
           end
        else
           print "mendeley: No papers found\n"
        end
        @snp.mendeley_updated = Time.zone.now
        @snp.save
        sleep(1)
      else
        print "mendeley: time threshold not met\n"
      end
   end
end
