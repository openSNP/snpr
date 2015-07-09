RSpec.describe 'snps/_snpedia_papers.html.erb' do
  let(:snpedia_paper) do
    double(:snpedia_paper, url: 'http://www.snpedia.com/index.php/Rs1234(A;C)',
                           summary: 'Green hair',
                           snp_variation: 'AC')
  end
  let(:snp) { double('snp', name: 'rs1234', snpedia_papers: [snpedia_paper]) }

  before do
    allow(view).to receive(:current_user).and_return(current_user)
  end

  context 'to the public' do
    let(:current_user) { nil }

    it 'displays a list of snpedia links' do
      render 'snps/snpedia_papers', snp: snp, user_snp: nil

      expect(rendered).to have_content('rs1234 A/C')
      expect(rendered).to have_content(snpedia_paper.summary)
      expect(rendered).to have_css("td > a[href=\"#{snpedia_paper.url}\"]")
    end
  end

  context 'to a logged-in user' do
    let(:current_user) { double('current user') }

    it 'displays a list of snpedia links' do
      render 'snps/snpedia_papers', snp: snp, user_snp: nil

      expect(rendered).to have_content('rs1234 A/C')
      expect(rendered).to have_content(snpedia_paper.summary)
      expect(rendered).to have_css("td > a[href=\"#{snpedia_paper.url}\"]")
    end

    context 'with a matching user_snp' do
      let(:user_snp) { double('user_snp', local_genotype: 'AC') }

      it 'displays the link bold' do
        render 'snps/snpedia_papers', snp: snp, user_snp: user_snp

        expect(rendered).to have_css("td > b > a[href=\"#{snpedia_paper.url}\"]")
      end
    end
  end
end
