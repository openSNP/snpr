# encoding: utf-8
require_relative '../test_helper'

class UsersControllerTest < ActionController::TestCase
  context "Users" do
    setup do
      Sunspot.stubs(:index)
      @user = Factory(:user, name: "The Dude")
      activate_authlogic
      assert_nil @controller.send(:current_user)
    end

    context "strangers" do
      should "get the index" do
        get :index
        assert_response :success
        assert_equal [@user], assigns(:users)
      end
 
      should "be able to register" do
        get :new
        assert_response :success
      end
 
      should "see users" do
        get :show, id: @user.id
        assert_response :success
        assert_equal @user, assigns(:user)
      end
 
      should "be able to create accounts" do
        assert_difference 'User.count' do
          put :create, user: { name: "Fubert Barfuß", password: 'jeheim',
            password_confirmation: 'jeheim', email: 'fubert@example.com'}, read: 1
        end
        assert_response :redirect
        assert_redirected_to user_path(User.last)
      end

      should "not be able to update" do
        post :update, id: @user.id, user: { name: "Blah Keks", user_phenotypes_attributes: [] }
        assert_redirected_to login_path
        @user.reload
        assert_not_equal "Blah Keks", @user.name
      end
 
      should "not be able to destroy" do
        assert_no_difference 'User.count' do
          post :destroy, id: @user.id
        end
        assert_redirected_to login_path
      end
    end

    context "other users" do
      setup do
        @controller = UsersController.new
        @other_user = Factory(:user, name: "The Nihilist")
        @session = UserSession.create(@other_user)
        assert_equal @other_user, @controller.send(:current_user)
      end

      teardown do
        @session.destroy
      end

      should "not edit" do
        get :edit, id: @user.id
        assert_redirected_to edit_user_path(@other_user)
      end

      should "not update" do
        old_name = @user.name.dup
        post :update, id: @user.id, user: { name: "Blah Keks", user_phenotypes_attributes: [] }
        assert_redirected_to edit_user_path(@other_user)
        @user.reload
        assert_equal old_name, @user.name
      end
     
      should "not destroy" do
        assert_no_difference 'User.count' do
          post :destroy, id: @user.id
        end
        assert_redirected_to edit_user_path(@other_user)
      end
    end

    context "themselves" do
      setup do
        @controller = UsersController.new
        @session = UserSession.create(@user)
        assert_equal @user, @controller.send(:current_user)
      end

      teardown do
        @session.destroy
      end

      should "be able to edit" do
        get :edit, id: @user.id
        assert_response :success
      end

      should "be able to update" do
        post :update, id: @user.id, user: { name: "Blah Keks", user_phenotypes_attributes: [] }
        assert_redirected_to edit_user_path(@user)
        @user.reload
        assert_equal "Blah Keks", @user.name
      end
         
      should "be able to destroy" do
        assert_difference 'User.count', -1 do
          post :destroy, id: @user.id
        end
        assert_redirected_to :root
      end
    end
  end
end
