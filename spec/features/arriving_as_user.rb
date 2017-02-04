RSpec.describe 'Arriving as user' do
  let(:snp) { double('snp', name: 'rs1234', snpedia_papers: [snpedia_paper]) }
  let!(:user) { create(:user, name: 'Potato Bill', snps: [snp]) }

  let(:snpedia_paper) do
    double(:snpedia_paper, url: 'http://www.snpedia.com/index.php/Rs1234(A;C)',
                           summary: 'Green hair',
                           snp_variation: 'AC',
                           created_at: '1969-07-20 20:17:40',
                           id: 1)
  end

  context 'as a signed-in user' do
    before do
      sign_in(user)
    end

    scenario 'the user arrives on landing page' do
      visit root_path

      expect(page).to have_content('Hello Potato!')
      expect(page).to have_content('rs1234')

      # Test Your last 30 updated SNPs feed
      expect(page).to have_content('Received new data from SNPedia')
    end
  end
end
