require "rubygems"
require "net/http"
require "json"

class PlosDetails
  include Sidekiq::Worker
  sidekiq_options :queue => :plos_details, :retry => 5, :unique => true

  def perform(plos_paper)
    return false
    plos_paper_id =
      if plos_paper.is_a?(Hash)
        plos_paper["plos_paper"]["id"].to_i
      else
        plos_paper.to_i
      end

    plos_paper = PlosPaper.find_by_id(plos_paper_id)
    key_handle = File.open(::Rails.root.to_s+"/key_plos.txt")
    api_key = key_handle.readline.rstrip

    detail_url = "http://alm.plos.org/articles/" + plos_paper.doi + ".json?api_key="+api_key
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

    plos_paper.reader = readers_total.to_i
    plos_paper.save
    print "-> sleep for 6 secs\n\n"
    sleep(6)
  end
end
