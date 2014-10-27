require_relative '../test_helper'

class PhenotypesControllerTest < ActionController::TestCase
  context "Phenotypes" do
    setup do
      @user = FactoryGirl.create(:user, name: "The Dude")
      activate_authlogic
      @phenotype = FactoryGirl.create(:phenotype)

      [ "Entered first phenotype",
        "Entered 5 additional phenotypes",
        "Entered 10 additional phenotypes",
        "Entered 20 additional phenotypes",
        "Entered 50 additional phenotypes",
        "Entered 100 additional phenotypes" ].each do |a|
        FactoryGirl.create(:achievement, award: a)
      end
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
        similar_phenotype = FactoryGirl.create(:phenotype)
        PhenotypeRecommender.any_instance.expects(:for).
          with(@phenotype.id.to_s).returns([similar_phenotype.id])
        get :show, id: @phenotype.id
        assert_response :success
        assert_equal @phenotype, assigns(:phenotype)
        assert_equal [similar_phenotype], assigns(:similar_phenotypes)
      end

      should "get the feed" do
        get :feed, id: @phenotype.id, format: 'rss'
        assert_response :success
      end

      # TODO: Strangers do not have email addresses (that we know of).
      # TODO: Hence denying access for them (see before_filter).
      should "not get genotypes" do
        get :get_genotypes, id: @phenotype.id, variation: "10000 cm"
        assert_redirected_to root_path
      end
    end

    context "other users" do
      setup do
        @controller = PhenotypesController.new
        @other_user = FactoryGirl.create(:user)
        @session = UserSession.create(@other_user)
      end

      should "make new ones" do
        get :new
        assert_response :success
      end

      should "create them" do
        Sidekiq::Client.expects(:enqueue).with do |worker, phenotype_id, user_id|
          worker == Mailnewphenotype &&
            phenotype_id.is_a?(Fixnum) &&
            user_id == @other_user.id
        end
        Sidekiq::Client.expects(:enqueue).with(Recommendvariations)
        Sidekiq::Client.expects(:enqueue).with(Recommendphenotypes)
        FactoryGirl.create(:achievement, award: "Created a new phenotype")
        assert_difference 'Phenotype.count' do
          assert_difference 'UserPhenotype.count' do
            put :create, phenotype: { characteristic: "Longest toe" },
              user_phenotype: { variation: "Thumb toe" }
          end
        end
        assert_redirected_to user_path(@other_user)
        assert_equal "Longest toe", Phenotype.last.characteristic
        assert_equal "Thumb toe", @other_user.user_phenotypes.last.variation
      end
    end
  end
end
