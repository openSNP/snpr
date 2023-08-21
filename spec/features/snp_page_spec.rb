# frozen_string_literal: true

RSpec.feature 'SNP page', :js do
  let!(:snp) { create(:snp) }
  let!(:snpedia_paper) do
    paper = create(:snpedia_paper)
    paper.update!(snps: [snp])
  end
  let!(:user) { create(:user, name: 'Alice') }
  let!(:user_snp) do
    create(:user_snp, snp: snp, user: user, local_genotype: 'AA')
  end
  let!(:another_user) { create(:user, name: 'Bob') }
  let!(:another_user_snp) do
    create(:user_snp, snp: snp, user: another_user, local_genotype: 'TT')
  end

  context 'as a signed-in user' do
    before do
      sign_in(user)
    end

    it 'is requested' do
      visit "/snps/#{snp.to_param}"

      expect(page).to have_content("SNP #{snp.name}")
      expect(page).to have_content("#{snp.name} A/C")
      expect(page).to have_content('AA')
    end

    it 'visit index page' do
      visit '/snps/'

      expect(page).to have_content(snp.name)
    end
  end

  context 'as not signed in user' do
    it 'displays SNP info' do
      visit "/snps/#{snp.to_param}"

      expect(page).to have_content("SNP #{snp.name}")
      expect(page).to have_content("#{snp.name} A/C")
    end

    it 'displays genotype and allele frequency graphs' do
      visit "/snps/#{snp.to_param}"

      expect(page).to have_content('Genotype Frequency')
      expect(page).to have_content('Allele Frequency')
      within('#frequencies') do
        expect(page).to have_content(user_snp.local_genotype)
      end
    end

    it 'shows users who share the SNP' do
      visit "/snps/#{snp.to_param}"

      click_on('Other users')

      expect(page).to have_content('Users who share this SNP')
      expect(page).to have_content(user_snp.local_genotype)
    end
  end
end
