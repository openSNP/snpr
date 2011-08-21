require 'resque'
require 'net/http'
require 'rexml/document'

class Plos
  @queue = :plos
  
  def self.perform(snp)
    @snp = Snp.find_by_id(snp["snp"]["id"].to_i)
    
    key_handle = File.open(::Rails.root.to_s+"key_plos.txt")
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
      all_elements[0][2].each do |singleton|
        first_author = singleton[2][0].to_s.gsub!(/<\/?str>/,"")
        print "first author:" +first_author+"\n"
        doi = singleton[4].to_s.gsub!(/<\/?str( name='id')?>/,"")
        print "doi: "+doi+"\n"
        pub_date = singleton[6].to_s.gsub!(/<\/?date( name='publication_date')?>/,"")
        print "pub. date: "+pub_date+"\n"
        title = singleton[7].to_s.gsub!(/<\/?str( name='title')?>/,"")
        print "title: "+title+"\n"
        
        if PlosPaper.find_all_by_doi(doi) == []
          @plos_paper = PlosPaper.new()
          @plos_paper.first_author = first_author
          @plos_paper.doi = doi
          @plos_paper.title = title
          @plos_paper.pub_date = pub_date
          @plos_paper.snp_id = @snp.id
          @plos_paper.save
          print "written new paper\n"
        end
      end
      else
        print "none found\n"
    end
  print "sleep for 5 secs\n\n"
  sleep(5)
  end
end