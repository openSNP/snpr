require_relative '../test_helper'

class GenotypesControllerTest < ActionController::TestCase
  context "Genotypes" do
    setup do
      Genotype.any_instance.expects(:parse_genotype)
      @genotype = FactoryGirl.create(:genotype)
      UserAchievement.delete_all
    end

    context "unauthenticated users" do
      should "not see certain things" do
        get :new
        assert_redirected_to :root
      end

      should "not be able to create genotypes" do
        put :create
        assert_redirected_to :root
      end

      should "see genotypes from any user" do
        get :show, id: @genotype.id
        assert_response :success
        assert_equal @genotype, assigns(:genotype)
      end

      should "get the rss feed" do
        get :feed, format: 'rss'
        assert_response :success
        assert_equal [@genotype], assigns(:genotypes)
      end

      should "not be able to destroy" do
        post :destroy, id: @genotype.id
        assert_redirected_to :root
      end
    end

    context "authenticated users" do
      setup do
        activate_authlogic
        @user = FactoryGirl.create(:user)
        UserSession.create(@user)
        @publishing_award = Achievement.find_by!(award: 'Published genotyping')
      end

      should "see the upload form" do
        get :new
        assert_response :success
      end

      should "be able to upload genotypes" do
        Genotype.any_instance.expects(:parse_genotype)
        FileUtils.cp("#{Rails.root}/testdata/testdatensatz1_23andme.txt",
                     "#{Rails.root}/test/fixtures")
        genotype_file = fixture_file_upload('testdatensatz1_23andme.txt')
        genotype_file.content_type = 'text/plain'
        assert_difference 'UserAchievement.count' do
          assert_difference 'Genotype.count' do
            put :create, commit: "Upload", genotype:
              { genotype: genotype_file, filetype: "23andme"}
          end
        end
        assert_redirected_to user_path(@user)
        assert_equal @publishing_award.id, UserAchievement.last.achievement_id
        FileUtils.rm("#{Rails.root}/test/fixtures/testdatensatz1_23andme.txt")
      end
    end
  end
end
