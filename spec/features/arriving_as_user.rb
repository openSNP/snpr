RSpec.describe 'Arriving as user' do
  let!(:user) { create(:user, name: 'Potato Bill') }
  let(:snpedia_paper) do
    double(:snpedia_paper, url: 'http://www.snpedia.com/index.php/Rs1234(A;C)',
                           summary: 'Green hair',
                           snp_variation: 'AC',
                           created_at: Time.new(2016).to_s)
  end
  let(:snp) { double('snp', name: 'rs1234', snpedia_papers: [snpedia_paper]) }

  context 'as a signed-in user' do

    before do
      sign_in(user)
    end

    scenario 'the user arrives on landing page' do
      visit root_path

      expect(page).to have_content('Hello Potato!')

    end
  end

end
