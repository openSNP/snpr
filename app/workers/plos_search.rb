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
    # In many weird cases on production, articles is nil
    # (can't reproduce on development)
    # For now the workaround is to use Array.wrap to make empty list
    # i.e, nil => []
    # - Philipp
    Array.wrap(articles).each do |article|
      import_article(article) if not article.nil?
    end
    snp.plos_updated!
    logger.info('sleeping for 6 seconds in honor of the API limits')
    sleep(6)
  end

  def import_article(article)
    plos_paper_attributes = {
      first_author: article.try(:authors).try(:first).try(:to_s),
      doi:          article.id,
      pub_date:     article.published_at,
      title:        article.title,
    }
    plos_paper = PlosPaper.find_or_initialize_by(doi: plos_paper_attributes[:doi])
    plos_paper.update_attributes!(plos_paper_attributes)
    plos_paper.snps << snp unless plos_paper.snps.include? snp
    Sidekiq::Client.enqueue(PlosDetails, plos_paper.id)
  end

  def perform_search
    # honoring API limits
    result = nil
    begin 
      Timeout.timeout(5) do
        result = client.search(snp.name, 0, 999)
      end
    rescue Timeout::Error
      logger.error("API call timed out")
      false
    end
    logger.info('Successfully called the API')
    result
  # the following rescue never seems to fire? can't find the error in the logs - Philipp
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
    ENV.fetch('PLOS_API_KEY')
  end
end
