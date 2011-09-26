require_relative '../test_helper'

class PhenotypesControllerTest < ActionController::TestCase
  context "Phenotypes" do
    setup do
      Sunspot.stubs(:index)
      @user = Factory(:user, name: "The Dude")
      activate_authlogic
      @phenotype = Factory :phenotype
    end

    context "strangers" do
      should "see them listed" do
        get :index
        assert_response :success
        assert_equal [@phenotype], assigns(:phenotypes)
      end

      should "not be able to make new ones" do
        get :new
        assert_redirected_to root_path
      end

      should "not be able to create them" do
        assert_no_difference 'Phenotype.count + UserPhenotype.count' do
          put :create, phenotype: { characteristic: "Longest toe" },
            user_phenotype: { variation: "Thumb toe" }
        end
        assert_redirected_to root_path
      end

      should "see them" do
        get :show, id: @phenotype.id
        assert_response :success
        assert_equal @phenotype, assigns(:phenotype)
      end

      should "get the feed" do
        get :feed, id: @phenotype.id
        assert_response :success
      end

      should "not get genotypes" do
        get :get_genotypes, id: @phenotype.id, variation: "10000 cm"
        assert_redirected_to root_path
      end
    end

    context "users" do
      setup do
        @session = UserSession.create(@other_user)
      end

      should "make new ones" do
        get :new
        assert_response :success
      end

      should "create them" do
        assert_difference 'Phenotype.count' do
          assert_difference 'UserPhenotype.count' do
            put :create, phenotype: { characteristic: "Longest toe" },
              user_phenotype: { variation: "Thumb toe" }
          end
        end
        assert_redirected_to user_path(@user)
        assert_equal "Longest toe", Phenotype.last.characteristic
        assert_equal "Thumb toe", @user.user_phenotypes.last.variation
      end
    end
  end
end
