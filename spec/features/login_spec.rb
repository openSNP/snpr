# frozen_string_literal: true

RSpec.describe 'Arriving at openSNP', sidekiq: :inline do
  let!(:user) { create(:user, name: 'Potato Bill', email: 'potato@example.com') }
  let!(:phenotype) { create(:phenotype, characteristic: 'Eye color') }

  context 'as a signed-in user' do
    before do
      sign_in(user)
    end

    scenario 'the user arrives on landing page' do
      visit root_path

      expect(page).to have_content('Hello, Potato')
      expect(page).to have_content('Eye color')
    end

    scenario 'tries to register' do
      visit '/signup/'
      expect(page).to have_content('You must be logged out to access this page')
    end
  end

  context 'as a signed-out user' do
    scenario 'user arrives on main page' do
      visit root_path
      expect(page).to have_content('Sign up')
      expect(page).to have_content('Download data')
      expect(page).to have_content('Sign In')
    end

    scenario 'user forgot their password' do
      visit root_path
      click_on('Sign In')
      click_on('Forgot password?')
      fill_in('Email', with: 'potato@example.com')
      perform_enqueued_jobs do
        click_on('Reset my password')
        expect(page).to have_content('Instructions to reset your password')
      end
      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to include('openSNP.org Password Reset Instructions')
      mail.parts.each do |p|
        expect(p.body.raw_source).to include(user.name)
        expect(p.body.raw_source).to include('password_resets')
      end
    end
  end
end
