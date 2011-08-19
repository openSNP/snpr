require 'net/http'
require 'rexml/document'

api_key = "INSERT_YOUR_CODE_HERE"

url = "http://api.plos.org/search?q="+ARGV[0]+"&api_key="+api_key

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
  end
end
