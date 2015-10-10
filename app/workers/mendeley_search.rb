require "rubygems"
require "net/http"
require "json"

class MendeleySearch
  include Sidekiq::Worker
  attr_reader :snp

  sidekiq_options :queue => :mendeley, :retry => 5, :unique => true

  def perform(snp_id)
    return false # until OAuth2 implementation
    @snp = Snp.where(id: snp_id).first
    if snp.nil?
      logger.error("Snp(#{snp_id}) not found.")
      return
    end
    if update_mendeley?
      search
    else
      logger.info("mendeley papers for #{snp.name} do not need to be updated") 
    end
  end

  def search
    page = 0
    items = 500
    begin
      result = Mendeley::API::Documents.
        search("\"#{snp.name}\"", { items: items, page: page })
      process_documents(result['documents'])
      page += 1
      sleep 1
    end while result['total_pages'].to_i > 0 &&
      result['total_pages'].to_i > result['current_page'].to_i

    snp.mendeley_updated = Time.now
    snp.ranking = snp.mendeley_papers.count +
      2 * snp.plos_papers.count + 5 * snp.snpedia_papers.count +
      2 * snp.genome_gov_papers.count + 2 * snp.pgp_annotations.count
    snp.save or raise(
      "could not save snp(#{snp.name}): #{snp.errors.full_messages.join(", ")}")

    if result["error"].present?
      logger.warn(
        "Mendeley API seems to be down.\nError is: #{result["error"]}")
    end
  end

  def process_documents(documents)
    if documents.blank?
      logger.info("mendeley: No papers found")
      return
    end
    documents.each do |document|
      uuid = document["uuid"].to_s
      mendeley_paper = MendeleyPaper.find_or_initialize_by(uuid: uuid)
      if mendeley_paper.new_record? || !mendeley_paper.valid?
        first_author = document["authors"].first
        if first_author.present?
          first_author = "#{first_author["forename"]} #{first_author["surname"]}"
        end

        logger.info("creating or updating paper")
        mendeley_paper.attributes = mendeley_paper.attributes.merge(
          title:        document['title'],
          mendeley_url: document['mendeley_url'],
          first_author: first_author,
          pub_year:     document['year'],
          uuid:         uuid,
          doi:          document["doi"].presence,
        )
        if !(mendeley_paper.valid? && mendeley_paper.save)
          logger.error("MendeleyPaper for #{snp.name} invalid.\n" <<
                       mendeley_paper.errors.full_messages.join(", "))
        else
          mendeley_paper.snps << snp unless mendeley_paper.snps.include? snp
        end
        Sidekiq::Client.enqueue(MendeleyDetails, mendeley_paper.id)
      end
    end
  end

  def update_mendeley?
    (snp.mendeley_updated.nil? || snp.mendeley_updated < 31.days.ago) &&
      snp.name.index("vg").nil? && snp.name.index("mt-").nil?
  end
end
