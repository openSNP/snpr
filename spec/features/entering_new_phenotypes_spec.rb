RSpec.feature 'Entering new phenotypes' do
  let!(:user) { create(:user) }

  before do
    sign_in(user)
  end

  scenario 'the user enters a new phenotype' do
    visit('/phenotypes')
    click_on('Add a new one!')
    fill_in('Characteristic', with: 'Eye count')
    fill_in('Description', with: 'How many eyes do you have?')
    fill_in('Variation', with: 10)
    click_on('Create Phenotype')
    expect(page.current_path).to eq("/users/#{user.id}")
    phenotype = Phenotype.find_by(characteristic: 'Eye count')
    expect(phenotype).to be_present
    expect(UserPhenotype.find_by(phenotype: phenotype, user: user).variation).to eq('10')
    expect(user.achievements.map(&:award))
      .to match_array(['Created a new phenotype', 'Entered first phenotype'])
  end
end
