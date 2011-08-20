require "rubygems"
require "net/http"
require "json"

api_key = "6ff805d8029f65f25841fe7d4fb91a5004e4fd1fd"

begin
  url = "http://api.mendeley.com/oapi/documents/search/"+ARGV[0]+"/?consumer_key="+api_key
rescue
  retry
end

resp = Net::HTTP.get_response(URI.parse(url))
data = resp.body
result = JSON.parse(data)

if result["total_results"] != 0
  result["documents"].each do |document|
    mendeley_url = document["mendeley_url"]
    first_author = document["authors"][0]["forename"]+" "+document["authors"][0]["surname"]
    title = document["title"]
    pub_year = document["year"]
    doi = document["doi"]
    
    print first_author.to_s+"\n"+mendeley_url.to_s+"\n"+title.to_s+"\n"+pub_year.to_s+"\n"+doi.to_s+"\n\n"
  end
end