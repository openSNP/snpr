# frozen_string_literal: true
RSpec.feature 'Delete a genotype', :js, sidekiq: :inline do
  let(:user) { create(:user, name: 'Gregor Mendel') }
  let!(:genotype) { create(:genotype, user: user, genotype_file_name: 'test.txt') }
  let(:award) { Achievement.find_by(award: 'Published genotyping') }
  let!(:user_achievement) do
    create(:user_achievement, achievement: award, user: user)
  end

  before do
    sign_in(user)
  end

  scenario 'the genotype exists' do
    visit root_path

    click_on('Gregor Mendel')
    click_on('Settings')
    click_on('Your genotypes')
    within('#genotypes') do
      page.accept_confirm(
        "Are you sure you want to delete genotype #{genotype.genotype_file_name}"
      ) { find('[title="delete"]').click }
    end

    expect(page).to have_content('Your Genotyping will be deleted. ' \
                                 'This may take a few minutes.')
    expect(Genotype.find_by(id: genotype.id)).to be_nil
    expect(UserAchievement.find_by(id: user_achievement.id)).to be_nil
  end
end
