class SnpToPhenotype
  include Sidekiq::Worker
  sidekiq_options :queue => :snp_phenotype, :retry => 5, :unique => true
  attr_reader :snp, :client

  def perform(snp_id)
    # could possible use the max_age limit here
    @snp = Snp.find(snp_id)
    if snp && valid_snp_names.include?(snp.name)
      score_pehnotype
    end
  end

  def score_phenotype
    # TODO:
    # - fetch papers metadata corresponding to the SNP
    # - fetch all the stored phenotypes
    # - search for each phenotype one by one in the papers' metadata
    # - maintain a hash of the phenotypes along with score
    # - return entire hash

  end

  def top_phenotypes(limit)
    # - return top phenotypes based on score from the hash
  end

  def perform_search
    # return an array of page-titles
    pages = client.list("#{snp.name}(")
    snpedia_updated = false
    (pages || []).each do |page|
      next unless page.include?('(')
      url = "http://www.snpedia.com/index.php/#{page}"
      # revision returns an int which grows with changes
      rev_id = client.revision(page).to_i
      snpedia_paper = SnpediaPaper.find_or_initialize_by(url: url)
      next if snpedia_paper.persisted? && snpedia_paper.revision == rev_id
      to_parse = client.get(page)
      next if to_parse.to_s.include?('#REDIRECT')
      /summary=(?<summary>.*)\}\}/m =~ to_parse
      snpedia_paper.update_attributes!(
        url: url, summary: summary, revision: rev_id)
      snpedia_paper.snps << snp unless snpedia_paper.snps.include? snp
      snpedia_updated = true
    end
    snp.snpedia_updated! if snpedia_updated
    if Rails.env == 'production'
      # Increase this value if the following error keeps on showing up
      # 'MediaWiki::APIError: API error: code 'internal_api_error_DBConnectionError', 
      # info 'Exception Caught: DB connection error: Too many connections'
      sleep(10)
    end
  end

  def valid_snp_names
    Marshal.load(File.read(Rails.root.join('marshalled_snpedia_array')))
  end
end
