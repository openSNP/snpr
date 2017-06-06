# frozen_string_literal: true
RSpec.feature 'SNP page' do
  let!(:snp) { create(:snp) }
  let!(:snpedia_paper) { create(:snpedia_paper, snps: [snp]) }
  let!(:user) {create(:user, name: 'Alice')}
  let!(:user_snp) {create(:user_snp, snp: snp, user: user, local_genotype: 'AA')}
  let!(:another_user) {create(:user, name: 'Bob')}
  let!(:another_user_snp) do
    create(:user_snp, snp: snp, user: another_user, local_genotype: 'TT')
  end


  context 'as a signed-in user' do
    before do
      sign_in(user)
    end

    scenario 'is requested' do
      visit "/snps/#{snp.to_param}"

      expect(page).to have_content("SNP #{snp.name}")
      expect(page).to have_content("#{snp.name} A/C")
      expect(page).to have_content('AA')
    end

    scenario 'visit index page' do
      visit '/snps/'

      expect(page).to have_content(snp.name)
    end
  end

  context 'as not signed in user' do
    scenario 'is requested' do
      visit "/snps/#{snp.to_param}"

      expect(page).to have_content("SNP #{snp.name}")
      expect(page).to have_content("#{snp.name} A/C")
      expect(page).not_to have_content('AA')
    end
  end
end
