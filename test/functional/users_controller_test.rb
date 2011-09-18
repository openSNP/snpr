# encoding: utf-8
require_relative '../test_helper'

class UsersControllerTest < ActionController::TestCase
  context "Users" do
    setup do
      Sunspot.stubs(:index)
      @user = Factory(:user)
      activate_authlogic
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

    should "not be updated by strangers" do
      post :update, id: @user.id, user: { name: "Blah Keks", user_phenotypes_attributes: [] }
      assert_redirected_to :root
      @user.reload
      assert_not_equal "Blah Keks", @user.name
    end

    should "not be updated by other users" do
      other_user = Factory(:user)
      post :update, id: @user.id, user: { name: "Blah Keks", user_phenotypes_attributes: [] }
      assert_redirected_to :root
      @user.reload
      assert_not_equal "Blah Keks", @user.name
    end

    should "be able to update themselves" do
      activate_authlogic
      UserSession.create(@user)
      post :update, id: @user.id, user: { name: "Blah Keks", user_phenotypes_attributes: [] }
      assert_redirected_to edit_user_path(@user)
      @user.reload
      assert_equal "Blah Keks", @user.name
    end

    should "not be destroyed by strangers" do
      assert_no_difference 'User.count' do
        post :destroy, id: @user.id
      end
      assert_redirected_to :root
    end

    should "not be destroyed by other users" do
      UserSession.create Factory(:user)
      assert_no_difference 'User.count' do
        post :destroy, id: @user.id
      end
      assert_redirected_to :root
    end

    should "be destroyed by themselves" do
      UserSession.create @user
      assert_difference 'User.count', -1 do
        post :destroy, id: @user.id
      end
      assert_redirected_to :root
    end
  end
end
