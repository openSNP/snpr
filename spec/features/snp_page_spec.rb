RSpec.feature 'SNP page' do
  let!(:snp) { create(:snp) }
  let!(:genotype) { create(:genotype) }
  let!(:user_snp) { UserSnp.new(snp, genotype, 'AC').save }
  let!(:user) { create(:user, genotypes: [genotype]) }

  let!(:snpedia_paper) { create(:snpedia_paper, snps: [snp]) }

  background do
    sign_in(user)
  end

  scenario 'is requested' do
    visit '/snps'

    expect(page).to have_content('AC')

    click_on snp.to_param

    expect(page).to have_content("SNP #{snp.name}")
    expect(page).to have_content("#{snp.name} A/C")
  end
end
