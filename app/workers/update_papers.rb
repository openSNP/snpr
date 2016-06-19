class UpdatePapers
  include Sidekiq::Worker
  MAX_AGE = 31.days

  PAPER_UPDATED_COLUMNS = {
    MendeleySearch => 'mendeley_updated',
    PlosSearch => 'plos_updated',
    Snpedia => 'snpedia_updated'
  }

  def perform
    PAPER_UPDATED_COLUMNS.each do |worker, column|
      Snp.where("#{column} < ?", max_age).pluck(:id).each do |snp_id|
        worker.perform_async(snp_id)
      end
    end
  end

  private

  def max_age
    MAX_AGE.ago
  end
end
