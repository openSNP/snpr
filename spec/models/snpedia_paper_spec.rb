RSpec.describe SnpediaPaper do
  subject do
    build(:snpedia_paper, url: 'http://www.snpedia.com/index.php/Rs1234(A;C)')
  end

  describe '#snp_variation' do
    it 'extracts the SNP variation from the url' do
      expect(subject.snp_variation).to eq('AC')
    end
  end
end
