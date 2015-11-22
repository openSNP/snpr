require "rubygems"
require "net/http"
require "json"

class MendeleyDetails
  include Sidekiq::Worker
  sidekiq_options :queue => :mendeley_details, :retry => 5, :unique => true

  def perform(mendeley_paper_id)
     mendeley_paper = MendeleyPaper.find_by_id(mendeley_paper_id.to_i)
     return if mendeley_paper.nil?

     key_handle = File.open(::Rails.root.to_s+"/key_mendeley.txt")
     api_key = key_handle.readline.rstrip

     detail_url = "http://api.mendeley.com/oapi/documents/details/" + mendeley_paper.uuid + "/?consumer_key="+api_key
     begin
        detail_resp = Net::HTTP.get_response(URI.parse(detail_url))
     rescue
        retry
     end

     detail_data = detail_resp.body
     detail_result = JSON.parse(detail_data)

     return if detail_result.nil?

     if detail_result["oa_journal"] != false
        mendeley_paper.open_access = true
     else
        mendeley_paper.open_access = false
     end

     logger.info('mendeley details: updated oa- and reader-status')
     if detail_result["stats"]
       mendeley_paper.reader = detail_result["stats"]["readers"]
     elsif detail_result["reader"]
       mendeley_paper.reader = detail_result["reader"]
     else
       mendeley_paper.reader = "Unknown"
     end

     mendeley_paper.save
     logger.info('sleep for 5 secs')
     sleep(5)
  end
end
