# frozen_string_literal: true

RSpec.describe 'Arriving at openSNP' do
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
      click_on('Reset my password')
      expect(page).to have_content('Instructions to reset your password')
      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to include('openSNP.org Password Reset Instructions')
      mail.parts.each do |p|
        expect(p.body.raw_source).to include(user.name)
        expect(p.body.raw_source).to include('password_resets')
      end
    end
  end

  context "for existing users" do
    let!(:user) do
      create(
        :user,
        email: "user@example.com",
        password_salt: "r138v6Tx3iqYNPPdfWnV",
        crypted_password: "$2a$10$8kSlpLxvB/psmMrmpIWmYOnM2wu/R8XUn8XvBaCTl6Tcu80LFudLe",
        persistence_token: "d078ab6ddb7375ca7fe652b2beef3e2dd2308c5c5a5cec803378436e710e201bc088d3f55f6858c187ed6ba30e7f2282ebb68b1cdddd36c7d8f607f5f178e51a",
        perishable_token: "lk8z9uiBMhJWoYx3syIM",
      )
    end

    it "allows them to log in" do
      visit(root_path)
      click_on("Sign In")
      fill_in('Email', with: 'user@example.com')
      fill_in('Password', with: 'secretly')
      click_on('Login')
      expect(page).to have_content('Login successful!')
    end
  end
end
