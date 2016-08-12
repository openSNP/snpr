RSpec.describe 'users/show' do
  let(:snpedia_paper) do
    double(:snpedia_paper, url: 'http://www.snpedia.com/index.php/Rs1234(A;C)',
                           summary: 'Green hair',
                           snp_variation: 'AC',
                           created_at: "#{Time.new 2016}" )
  end
  let(:snp) { double('snp', name: 'rs1234', snpedia_papers: [snpedia_paper]) }

  context 'to a logged-in user' do
    let(:current_user) { double('current user') }

    it 'displays that this SNP was updated recently' do
      render 'users/user_is_user', user: current_user

      expect(rendered).to have_content('Received new data from Mendeley!')
    end
  end
end
