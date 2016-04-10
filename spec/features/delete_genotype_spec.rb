RSpec.feature 'Delete a genotype', sidekiq: :inline do
  let(:user) { create(:user) }
  let!(:genotype) { create(:genotype, user: user) }
  let(:award) { Achievement.find_by(award: 'Published genotyping') }
  let!(:user_achievement) do
    create(:user_achievement, achievement: award, user: user)
  end

  before do
    sign_in(user)
  end

  scenario 'the genotype exists' do
    visit root_path

    click_on('My Account')
    click_on('Settings')
    click_on('Deleting')
    click_on('Delete genotype')

    expect(page).to have_content('Your Genotyping will be deleted. ' \
                                 'This may take a few minutes.')
    expect(Genotype.find_by(id: genotype.id)).to be_nil
    expect(UserAchievement.find_by(id: user_achievement.id)).to be_nil
  end
end
