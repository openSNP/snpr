# frozen_string_literal: true
RSpec.feature 'Not-yet-entered variations list', :js do
  let!(:user) { create(:user) }
  let!(:phenotype1) { create(:phenotype, characteristic: 'Eye count') }
  let!(:phenotype2) { create(:phenotype, characteristic: 'Tentacle count') }
  let!(:phenotype3) { create(:phenotype, characteristic: 'Beard Color') }

  before do
    sign_in(user)
  end

  scenario 'a user enters a variation from the list' do
    expect(page.current_path).to eq("/users/#{user.id}")
    expect(page).to have_content('Variations you did not enter yet (3)')
    expect(page).to have_content('Eye count')
    find("[href=\"#new_user_phenotype_modal#{phenotype1.id}\"]").click
    fill_in('user_phenotype[variation]', with: '1000')
    click_on('Save')
    expect(page).to have_content('Variations you did not enter yet (2)')
    expect(UserPhenotype.find_by(user: user, phenotype: phenotype1).variation).to eq('1000')
  end
end
