class LastUpdatedSnpsService
  def self.get_last_thirty_updated_snps
    [SnpediaPaper, MendeleyPaper, GenomeGovPaper, PlosPaper].flat_map do |papers|
      papers.last(30).select do |paper|
        paper.snps.any? { |s| s.users.exists?(@user.id) }
      end
    end.sort_by(&:updated_at).reverse.take(30)
  end
end
