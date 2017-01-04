# frozen_string_literal: true
RSpec.feature 'Messaging' do
  let!(:alice) { create(:user, name: 'Alice') }
  let!(:bob) { create(:user, name: 'Bob') }

  scenario 'a user sends a messages' do
    sign_in(alice)

    click_on('My Account')
    click_on('Messages')
    click_on('Write a new message')

    select('Bob', from: 'To')
    fill_in('Subject', with: 'O HAI!')
    fill_in('Body', with: 'Something, something, something...')

    click_on('Send')

    sign_out

    sign_in(bob)

    click_on('My Account')
    click_on('Messages')

    click_on('O HAI!')

    expect(page).to have_content('From: Alice')
    expect(page).to have_content('Subject: O HAI!')
    expect(page).to have_content('Something, something, something...')
  end
end
