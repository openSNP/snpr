require "rubygems"
require "net/http"
require "json"

class PlosDetails
  include Sidekiq::Worker
  sidekiq_options :queue => :plos_details, :retry => 5, :unique => true

  def perform(plos_paper)
    plos_paper_id =
      if plos_paper.is_a?(Hash)
        plos_paper["plos_paper"]["id"].to_i
      else
        plos_paper.to_i
      end

    plos_paper = PlosPaper.find_by_id(plos_paper_id)

    detail_url = "http://alm.plos.org/api/v3/articles/#{plos_paper.doi}?" \
                 "api_key=#{ENV.fetch('PLOS_API_KEY')}"

    detail_resp = Net::HTTP.get_response(URI.parse(detail_url))
    detail_data = detail_resp.body
    detail_result = JSON.parse(detail_data)

    # detail can be several results, take first one
    # looks like it's always one?
    readers_total = detail_result[0]["views"]

    # Others to get are 'shares', 'bookmarks', 'citations',
    #   and a ton of other interesting things

    plos_paper.reader = readers_total.to_i
    plos_paper.save
    sleep(6)
  end
end
