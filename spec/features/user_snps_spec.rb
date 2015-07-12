RSpec.feature 'User-SNPs' do
  let!(:user) { create(:user, name: 'Justin Timberlake') }
  let!(:snp) { create(:snp, name: 'rs123') }
  let!(:genotype) { create(:genotype, user: user) }
  let!(:user_snp) { UserSnp.new(snp, genotype, 'AC').save }

  scenario 'a SNP name was not provided' do
    visit '/user_snps'

    expect(page).to have_content('Something went wrong.')
  end

  scenario 'a SNP name was provided' do
    visit '/user_snps?snp_name=rs123'

    expect(page).to have_content('Justin Timberlake')
    expect(page).to have_content('AC')
  end
end
