# frozen_string_literal: true
class UpdatePapers
  include Sidekiq::Worker
  sidekiq_options retry: false, unique: true
  MAX_AGE = 31.days

  PAPER_UPDATED_COLUMNS = {
    MendeleySearch => 'mendeley_updated',
    PlosSearch => 'plos_updated',
    Snpedia => 'snpedia_updated'
  }.freeze

  def perform
    PAPER_UPDATED_COLUMNS.each do |worker, column|
      snp_ids(column).each do |snp_id|
        worker.perform_async(snp_id)
      end
    end
  end

  private

  def snp_ids(column)
    Snp.where("#{column} < ?", max_age).pluck(:id)
  end

  def max_age
    MAX_AGE.ago
  end
end
