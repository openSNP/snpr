# frozen_string_literal: true

module Authlogic
  module RequestSpecHelper
    def sign_in(user)
      post(
        user_session_path,
        params: {
          user_session: {
            email: user.email,
            password: 'strengjeheim'
          }
        },
      )
    end
  end

  module FeatureSpecHelper
    def sign_in(user)
      visit '/signin'

      expect(page).to have_content('Login')

      fill_in('Email', with: user.email)
      fill_in('Password', with: 'strengjeheim')

      click_on('Login')

      expect(page).to have_content 'Login successful'
    end

    def sign_out(user)
      click_on(user.name)
      click_on('Sign out')

      expect(page).to have_content('Logout successful!')
    end
  end
end

RSpec.configure do |config|
  config.include Authlogic::RequestSpecHelper, type: :request
  config.include Authlogic::FeatureSpecHelper, type: :feature
end
