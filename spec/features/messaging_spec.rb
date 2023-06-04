# frozen_string_literal: true
RSpec.feature 'Messaging', :js do
  let!(:alice) { create(:user, name: 'Alice') }
  let!(:bob) { create(:user, name: 'Bob') }

  let!(:to_alice) do
    create(:message, user: bob,
                     from_id: bob.id,
                     to_id: alice.id,
                     sent: true,
                     subject: 'Delete Me')
  end

  let!(:from_bob) do
    create(:message, user: alice,
                     from_id: bob.id,
                     to_id: alice.id,
                     subject: 'Delete Me')
  end

  scenario 'user successfully deletes message' do
    sign_in(alice)

    click_on('Alice')
    click_on('Your messages')
    click_on('Delete Me')
    click_on('Delete')

    expect(page).to have_content('Message deleted')
  end

  scenario 'user tries deleting other users message' do
    sign_in(alice)
    page.driver.submit :delete, "/messages/#{to_alice.id}", {}
    expect(page).to have_content('Oops! Thats none of your business')
  end

  scenario 'user tries reading other ppls messages' do
    sign_in(alice)
    visit "/messages/#{to_alice.id}"

    expect(page).to have_content('Oops! Thats none of your business')
  end

  scenario 'a user sends a messages' do
    sign_in(alice)

    click_on('Alice')
    click_on('Your messages')
    click_on('Write a new message')

    select('Bob', from: 'To')
    fill_in('Subject', with: 'O HAI!')
    fill_in('Body', with: 'Something, something, something...')

    click_on('Send')

    sign_out(alice)

    sign_in(bob)

    click_on('Bob')
    click_on('Your messages')

    click_on('O HAI!')

    expect(page).to have_content('From: Alice')
    expect(page).to have_content('Subject: O HAI!')
    expect(page).to have_content('Something, something, something...')
  end
end
