require "resque"
require "rubygems"
require "net/http"
require "json"

class PlosDetails
   @queue = :plos_details

   def self.perform(plos_paper)
      @Plos_paper = PlosPaper.find_by_id(plos_paper["plos_paper"]["id"].to_i)

      key_handle = File.open(::Rails.root.to_s+"/key_plos.txt")
      api_key = key_handle.readline.rstrip

      detail_url = "http://alm.plos.org/articles/" + @Plos_paper.doi + ".json?api_key="+api_key
      begin
         detail_resp = Net::HTTP.get_response(URI.parse(detail_url))
      rescue
         retry
      end

      detail_data = detail_resp.body
      detail_result = JSON.parse(detail_data)

      print "plos details: updated reader-status\n"
      print detail_result
      readers_total = detail_result["article"]["events_count"].to_i
      
      @Plos_paper.reader = readers_total.to_i
      @Plos_paper.save
      print "-> sleep for 5 secs\n\n"
      sleep(5)
   end
end
