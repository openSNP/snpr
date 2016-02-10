require 'rubygems'
require 'net/http'
require 'json'

class PlosDetails
  include Sidekiq::Worker
  sidekiq_options :queue => :plos_details, :retry => 5, :unique => true

  def perform(plos_paper)
    plos_paper_id =
      if plos_paper.is_a?(Hash)
        plos_paper['plos_paper']['id'].to_i
      else
        plos_paper.to_i
      end

    plos_paper = PlosPaper.find_by_id(plos_paper_id)

    detail_url = "http://alm.plos.org/api/v3/articles/#{plos_paper.doi}?" \
                 "api_key=#{ENV.fetch('PLOS_API_KEY')}"

    detail_resp = Net::HTTP.get_response(URI.parse(detail_url))
    # did we get a proper response?
    unless detail_resp.is_a? Net::HTTPSuccess
      # don't bother parsing broken or empty output
      sleep 6
      return
    end

    detail_data = detail_resp.body
    detail_result = JSON.parse(detail_data)

    # as of 2016-02-10, body is of format
    # {'doi':'10.1371/journal.pone.0080003','title':'Plasma Interferon-Gamma-Inducible Protein-10 Levels Are Associated with Early, 
    # but Not Sustained Virological Response during Treatment of Acute or Early Chronic HCV Infection',
    # 'url':'http://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0080003',
    # 'mendeley':'21a5a7c7-9531-38d1-9555-871b62ebf9d1','pmid':'24278230','pmcid':'3835825','publication_date':'2013-11-20T08:00:00Z',
    # 'update_date':'2016-02-09T23:22:24Z','views':1720,'shares':0,'bookmarks':5,'citations':4,
    # currently we're only interested in 'views', but there's also tons of other data coming back (shares/comments on reddit, for example)
    # 'sources':
    # [{'name':'openedition','display_name':'OpenEdition','events_url':null,'update_date':'2013-11-21T11:15:10Z',
    # 'metrics':{'pdf':0,'html':0,'shares':0,'groups':0,'comments':0,'likes':0,'citations':0,'total':0}},
    # {'name':'reddit','display_name':'Reddit','events_url':null,'update_date':'2015-12-30T13:12:53Z',
    # 'metrics':{'pdf':0,'html':0,'shares':0,'groups':0,'comments':0,'likes':0,'citations':0,'total':0}},
    # ....
    # {'name':'orcid','display_name':'ORCID','events_url':null,'update_date':'2016-02-03T09:06:31Z',
    # 'metrics':{'pdf':0,'html':0,'shares':0,'groups':0,'comments':0,'likes':0,'citations':0,'total':0}}]}
    #
    readers_total = detail_result['views']

    plos_paper.reader = readers_total.to_i
    plos_paper.save
    sleep(6)
  end
end
