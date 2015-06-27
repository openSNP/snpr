RSpec.feature 'SNP page' do
  let!(:snp) { create(:snp) }
  let!(:snpedia_paper) { create(:snpedia_paper, snps: [snp]) }

  scenario 'is requested' do
    visit "/snps/#{snp.to_param}"

    expect(page).to have_content("SNP #{snp.name}")
    expect(page).to have_content("#{snp.name} A/C")
  end
end
