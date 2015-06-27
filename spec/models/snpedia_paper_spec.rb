RSpec.describe SnpediaPaper do
  subject do
    build(:snpedia_paper, url: 'http://www.snpedia.com/index.php/Rs1234(A;C)')
  end

  describe '#local_genotype' do
    it 'extracts the local genotype from the url' do
      expect(subject.local_genotype).to eq('AC')
    end
  end
end
