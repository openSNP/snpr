require "resque"
require "rubygems"
require "net/http"
require "json"

class Mendeley
  @queue = :mendeley
  
  def self.perform(snp)
    @snp = Snp.find_by_id(snp["snp"]["id"].to_i)
    
    api_key = "6ff805d8029f65f25841fe7d4fb91a5004e4fd1fd"
    
    url = "http://api.mendeley.com/oapi/documents/search/"+@snp.name+"/?consumer_key="+api_key
    
    begin
      resp = Net::HTTP.get_response(URI.parse(url))
    rescue
      retry
    end
    
    data = resp.body
    result = JSON.parse(data)
    print result
    print "\n"
    
    if result["total_results"] != 0
      result["documents"].each do |document|
        mendeley_url = document["mendeley_url"]
        first_author = document["authors"][0]["forename"]+" "+document["authors"][0]["surname"]
        title = document["title"]
        pub_year = document["year"]
        doi = document["doi"]

        print first_author.to_s+"\n"+mendeley_url.to_s+"\n"+title.to_s+"\n"+pub_year.to_s+"\n"+doi.to_s+"\n\n"
        
        if MendeleyPaper.find_all_by_mendeley_url(mendeley_url) == []
          @mendeley_paper = MendeleyPaper.new()
          @mendeley_paper.mendeley_url = mendeley_url
          @mendeley_paper.first_author = first_author
          @mendeley_paper.pub_year = pub_year
          @mendeley_paper.title = title
          if doi != []
            @mendeley_paper.doi = doi
          end
          @mendeley_paper.snp_id = @snp.id
          @mendeley_paper.save
          print "Written paper\n"
        end
      end
    else
      print "none found\n"
    end
    print "sleep for 5 secs\n"
    sleep(5)
  end
end