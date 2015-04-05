require_relative '../test_helper'

class FitbitProfilesControllerTest < ActionController::TestCase
  context 'Fitbit profiles' do
    setup do
      @user = FactoryGirl.create(:user)
      @fitbit_profile = FactoryGirl.create(:fitbit_profile, user: @user)
    end

    should 'show up' do
      get 'show', id: @fitbit_profile.id
      assert_response :ok
    end
  end
end
