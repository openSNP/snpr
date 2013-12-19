# See http://api.plos.org/solr/faq/#solr_api_recommended_usage for API limits
require 'plos'

class PlosSearch
  include Sidekiq::Worker
  sidekiq_options queue: :plos, unique: true
  attr_reader :snp, :client

  def perform(snp_id)
    @snp = Snp.where(id: snp_id).first
    return false if @snp.nil? || snp_illegal? || recently_updated?
    @client = PLOS::Client.new(self.class.api_key)
    articles = perform_search
    articles.each do |article|
      import_article(article)
    end
    snp.plos_updated!
    logger.info('sleeping for 6 seconds in honor of the API limits')
    sleep(6)
  end

  def import_article(article)
    plos_paper_attributes = {
      first_author: article.authors.first.to_s,
      doi:          article.id,
      pub_date:     article.published_at,
      title:        article.title,
      snp_id:       snp.id,
    }
    plos_paper = PlosPaper.find_or_initialize_by_doi(plos_paper_attributes[:doi])
    plos_paper.update_attributes!(plos_paper_attributes)
    plos_paper.snps << snp
    Sidekiq::Client.enqueue(PlosDetails, plos_paper.id)
  end

  def perform_search
    # honoring API limits
    result = nil
    Timeout.timeout(5) do
      result = client.search(snp.name, 0, 999)
    end
    logger.info('Successfully called the API')
    result
  rescue => e
    logger.error("API call unsuccessful: Error was: #{e.class}: #{e.message}")
    raise e
  end

  def snp_illegal?
    # we don't need mitochondrial or VG-SNPs as these just result in noise
    # from the PLOS API
    forbidden_names = ["mt-", "vg"]
    if forbidden_names.any? { |part| snp.name[part] }
      logger.info("Snp #{snp.name} is a mitochondrial or vg snp")
      true
    else
      false
    end
  end

  def recently_updated?
    # we don't need to update snps that have been updated in the last month
    if snp.plos_updated > 31.days.ago
      logger.info("time threshold for #{snp.name} not met")
      true
    else
      false
    end
  end

  def logger
    @plos_logger ||=
      Logger.new(Rails.root.join("log/plos_#{Rails.env}.log"), 'weekly')
  end

  def self.api_key
    # TODO: put in APP_CONFIG
    File.read(Rails.root.join("key_plos.txt")).strip
  end
end
