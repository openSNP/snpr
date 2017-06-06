# frozen_string_literal: true

RSpec.describe 'Password changing' do
  let!(:user) { create(:user, name: 'Queen Anne', email: 'anne@the.uk') }

  context 'as a signed-in user' do
    before do
      sign_in(user)
    end

    scenario 'the password is too short' do
      visit "/users/#{user.id}/changepassword"
      fill_in('Password', with: '1710')
      fill_in('Confirmation', with: '1710')
      click_on('Update Information')
      expect(page).not_to have_content("Password confirmation doesn't match Password")
      expect(page).to have_content('Password is too short')
    end

    scenario 'confirmation doesnt match' do
      visit "/users/#{user.id}/changepassword"
      fill_in('Password', with: 'yetanothermary')
      fill_in('Confirmation', with: 'yetanothermarry')
      click_on('Update Information')
      expect(page).to have_content("Password confirmation doesn't match Password")
      expect(page).not_to have_content('Password is too short')
    end

    scenario 'finally got it right' do
      visit "/users/#{user.id}/changepassword"
      fill_in('Password', with: 'QueenAnnesRevenge')
      fill_in('Confirmation', with: 'QueenAnnesRevenge')
      click_on('Update Information')
      expect(page).not_to have_content("Password confirmation doesn't match Password")
      expect(page).not_to have_content('Password is too short')
    end
  end
end
