require "resque"
require "rubygems"
require "net/http"
require "json"

class MendeleySearch
   include Resque::Plugins::UniqueJob
   @queue = :mendeley

   def self.perform(snp_id)
     snp = Snp.find(snp_id)
     if (snp.mendeley_updated.nil? || snp.mendeley_updated < 31.days.ago) && (snp.name.index("vg").nil? == true && snp.name.index("mt-").nil? == true)
       page = 0
       items = 500
       documents = []
       begin
         begin
           result = Mendeley::API::Documents.
             search(snp.name, { items: items, page: page })
           documents.concat(result['documents'])
           puts result["total_pages"]
           puts page
           page += 1
         rescue => e
           puts e.class
           puts e.message
           puts "retrying..."
           sleep 1
           retry
         end
         sleep 1
       end while result['total_pages'].to_i > 0 &&
         result['total_pages'].to_i > result['current_page'].to_i

       if result["error"].present?
         puts "Mendeley API seems to be down."
         puts "Error is:"
         puts result["error"] 
         return
       elsif documents.present?
         puts "mendeley: Found #{documents.size} papers"
         documents.each do |document|
           uuid = document["uuid"].to_s
           begin
             first_author = document["authors"].first["forename"] + ' ' +
               document["authors"].first["surname"]
           rescue => e
             puts "Something wrong in #{document["authors"]}: #{e.class}: #{e.message}"
             first_author = "Unknown"
           end

           if MendeleyPaper.where(uuid: uuid).count == 0
             puts "-> paper is new"
             @mendeley_paper = MendeleyPaper.new(
               snp_id:       snp.id,
               title:        document['title'],
               mendeley_url: document['mendeley_url'],
               first_author: first_author,
               pub_year:     document['year'],
               uuid:         uuid
             )
             doi = document["doi"]
             @mendeley_paper.doi = doi  if doi.present?
             @mendeley_paper.save
             snp.ranking = snp.mendeley_paper.count +
               2*snp.plos_paper.count + 5*snp.snpedia_paper.count +
               2*snp.genome_gov_paper.count + 2*snp.pgp_annotation.count
  
             puts "-> Written paper"
           else
             puts "-> paper is old"
             @mendeley_paper = MendeleyPaper.find_by_uuid(uuid)
             if @mendeley_paper.title == ""
               puts "-> paper is broken and will be replaced now"
               @mendeley_paper.update_attributes(
                 :title => document['title'],
                 :snp_id => snp.id,
                 :mendeley_url => document['mendeley_url'],
                 :first_author => first_author,
                 :pub_year => document['year']
               ) 
             end
           end
           Resque.enqueue(MendeleyDetails, @mendeley_paper.id)
         end
       else
         puts "mendeley: No papers found"
       end
       snp.mendeley_updated = Time.zone.now
       snp.save
     else
       puts "mendeley: time threshold not met"
     end
   end
end
