require "resque"
require "rubygems"
require "net/http"
require "json"

class MendeleyDetails
   @queue = :mendeley_details

   def self.perform(mendeley_paper)
      @mendeley_paper = MendeleyPaper.find_by_id(mendeley_paper["mendeley_paper"]["id"].to_i)

      key_handle = File.open(::Rails.root.to_s+"/key_mendeley.txt")
      api_key = key_handle.readline.rstrip

      detail_url = "http://api.mendeley.com/oapi/documents/details/" + @mendeley_paper.uuid + "/?consumer_key="+api_key
      begin
         detail_resp = Net::HTTP.get_response(URI.parse(detail_url))
      rescue
         retry
      end

      detail_data = detail_resp.body
      detail_result = JSON.parse(detail_data)

      if detail_result["oa_journal"] != false
         @mendeley_paper.open_access = true
      else
         @mendeley_paper.open_access = false
      end

      print "mendeley details: updated oa- and reader-status\n"
      @mendeley_paper.reader = detail_result["stats"]["readers"]
      @mendeley_paper.save
      print "-> sleep for 5 secs\n"
      sleep(5)
   end
end
