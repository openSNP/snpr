
require 'net/http'
require 'rexml/document'

class Plos
  include Sidekiq::Worker
  sidekiq_options :queue => :plos
  
  def is_illegal_snp(name)
    # we don't need mitochondrial or VG-SNPs as these just result in noise 
    # from the PLOS API
    forbidden_names = ["mt-", "vg"]
    if forbidden_names.any? { |part| name[part] }
      log "plos: Snp #{name} is a mitochondrial or vg snp"
      return true
    end
  end

  def is_old_snp(snp)
    # we don't need to update snps that have been updated in the last month
    if snp.plos_updated > 31.days.ago
      log "plos: time threshold for #{snp.name} not met"
      return true
    end
  end

  def perform(snp_id)
    # Logging stuff
    Rails.logger.level = 0
    Rails.logger = Logger.new("#{Rails.root}/log/plos_#{Rails.env}.log")

    # Get SNP
    @snp = Snp.find(snp_id)

    return false if is_illegal_snp(@snp.name) or is_old_snp(@snp)

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
    # check if there are any papers to add...
    if all_elements[0][2].index("numFound='0'") != -1
        log "plos: none found\n"
        return false
    end

    log "plos: got papers"
    log "all elements: #{all_elements}"
    log "Checking: #{all_elements[0][2]}"
    all_elements[0][2].each do |singleton|
        log "plos: Looking at: #{singleton}"
        log "Trying #{singleton[7]}"
        first_author = singleton[2][0].to_s.gsub!(/<\/?str>/,"")
        log "first author: #{first_author}"
        doi = singleton[4].to_s.gsub!(/<\/?str( name='id')?>/,"")
        log "doi: #{doi}"
        pub_date = singleton[6].to_s.gsub!(/<\/?date( name='publication_date')?>/,"")
        log "pub_date: #{pub_date}"
        title = CGI.unescapeHTML(singleton[7].to_s.gsub!(/<\/?str( name='title_display')?>/,""))
        log "full title: #{title}"

        if PlosPaper.find_all_by_doi(doi) == []
          @plos_paper = PlosPaper.new(:first_author => first_author, :doi => doi, :title => title, :pub_date => pub_date, :snp_id => @snp.id)
          @plos_paper.save
          log "-> written new paper\n"
          @snp.ranking = @snp.mendeley_paper.count + 2*@snp.plos_paper.count + 5*@snp.snpedia_paper.count + 2*@snp.genome_gov_paper.count + 2*@snp.pgp_annotation.count
        else
          log "-> paper is old"
          @plos_paper = PlosPaper.find_by_doi(doi)
        end
        Sidekiq::Client.enqueue(PlosDetails,@plos_paper)
    end
    @snp.plos_updated = Time.zone.now
    @snp.save
    log "plos: sleep for 5 secs\n"
    sleep(5)
  end

  def log msg
    Rails.logger.info "#{DateTime.now}: #{msg}"
  end
end

