RSpec.feature 'Upload a genotype' do
  let(:user) { create(:user, name: 'Gregor Mendel') }

  before do
    sign_in(user)
  end

  scenario 'uploads first genotype' do
    visit '/genotypes/new'
    attach_file('genotype[genotype]', File.absolute_path('test/data/23andMe_test.csv'))
    choose '23andme-format'
    click_on 'Upload'
    expect(page).to have_content('Genotype was successfully uploaded!')
    expect(page).to have_content("You've unlocked an achievement:")
  end
end
