# frozen_string_literal: true
RSpec.feature 'Fitbit profiles' do
  let!(:user) { create(:user) }
  let!(:fitbit_profile) { create(:fitbit_profile, user: user) }

  scenario 'are shown' do
    visit '/fitbit'

    expect(page).to have_content('Listing all connected Fitbit accounts')
  end
end
