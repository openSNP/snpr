# frozen_string_literal: true

RSpec.feature 'OpenHumans page' do
  let!(:user) { create(:user, name: 'Alice') }

  context 'as not signed in user' do
    scenario 'visit open humans index' do
      visit '/openhumans'
      expect(page).to have_content('Accounts with an Open Humans connection')
      expect(page).not_to have_content('Connect to Open Humans')
    end

    scenario 'visit open humans connector' do
      visit '/openhumans/new'
      expect(page).to have_content('You must be logged in to access this page')
    end
  end

  context 'as a signed-in user' do
    before do
      sign_in(user)
    end
    scenario 'visit open humans index' do
      visit '/openhumans'
      expect(page).to have_content("Accounts with an Open Humans connection")
      expect(page).to have_content('Connect to Open Humans')
    end

    scenario 'visit open humans connector' do
      visit '/openhumans/new'
      expect(page).not_to have_content('You must be logged in to access this page')
    end
  end
end
