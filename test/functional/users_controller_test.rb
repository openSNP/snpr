# encoding: utf-8
require_relative '../test_helper'

class UsersControllerTest < ActionController::TestCase
  context "Users" do
    setup do
      Sunspot.stubs(:index)
      @user = Factory(:user)
    end

    should "be indexed" do
      get :index
      assert_response :success
      assert_equal [@user], assigns(:users)
    end

    should "be new" do
      get :new
      assert_response :success
    end

    should "be shown" do
      get :show, id: @user.id
      assert_response :success
      assert_equal @user, assigns(:user)
    end

    should "be created" do
      assert_difference 'User.count' do
        put :create, user: { name: "Fubert Barfuß", password: 'jeheim',
          password_confirmation: 'jeheim', email: 'fubert@example.com'}, read: 1
      end
      assert_response :redirect
      assert_redirected_to user_path(User.last)
    end

    should "be updated" do
      post :update, id: @user.id, user: { name: "Blah Keks", user_phenotypes_attributes: [] }
      assert_response :success
      @user.reload
      assert_equal "Blah Keks", @user.name
    end
  end
end

