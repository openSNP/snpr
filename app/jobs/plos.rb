require 'resque'
require 'net/http'
require 'rexml/document'

class Plos
  include Sidekiq::Worker
  include Resque::Plugins::UniqueJob
  @queue = :plos
  
  def perform(snp_id)
    @snp = Snp.find(snp_id)
    if @snp.plos_updated < 31.days.ago && @snp.name.index("vg").nil? &&
        @snp.name.index("mt-").nil?
      key_handle = File.open(::Rails.root.to_s+"/key_plos.txt")
      api_key = key_handle.readline.rstrip

      url = "http://api.plos.org/search?q="+@snp.name+"&api_key="+api_key

      begin
        xml_data = Net::HTTP.get_response(URI.parse(url)).body
      rescue      # yep, this sucks, but the http-parser likes to break down without any reason, so this retries...
        retry
      end

      doc = REXML::Document.new(xml_data)

      all_elements = doc.elements.to_a
      if all_elements[0][2].index("numFound='0'") != -1     # check if there are any papers to add...
        puts "plos: got papers"
        all_elements[0][2].each do |singleton|
          puts "plos: Looking at #{singleton}"
          first_author = singleton[2][0].to_s.gsub!(/<\/?str>/,"")
          doi = singleton[4].to_s.gsub!(/<\/?str( name='id')?>/,"")
          pub_date = singleton[6].to_s.gsub!(/<\/?date( name='publication_date')?>/,"")
          title = CGI.unescapeHTML(singleton[7].to_s.gsub!(/<\/?str( name='title_display')?>/,""))
          print title

          if PlosPaper.find_all_by_doi(doi) == []
            @plos_paper = PlosPaper.new(:first_author => first_author, :doi => doi, :title => title, :pub_date => pub_date, :snp_id => @snp.id)
  		  @plos_paper.save
            print "-> written new paper\n"
            @snp.ranking = @snp.mendeley_paper.count + 2*@snp.plos_paper.count + 5*@snp.snpedia_paper.count + 2*@snp.genome_gov_paper.count + 2*@snp.pgp_annotation.count
          else
            print "-> paper is old"
            @plos_paper = PlosPaper.find_by_doi(doi)
          end
          Resque.enqueue(PlosDetails,@plos_paper)
        end
        else
          print "plos: none found\n"
      end
      @snp.plos_updated = Time.zone.now
      @snp.save
      print "plos: sleep for 5 secs\n"
      sleep(5)
    else
      print "plos: time threshold not met\n"
    end
  end
end
