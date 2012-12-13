require_relative '../test_helper'

class GenotypesControllerTest < ActionController::TestCase
  context "Genotypes" do
    setup do
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
        get :feed
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
        @publishing_award = FactoryGirl.create(:achievement, award: "Published genotyping")
      end

      should "see the upload form" do
        get :new
        assert_response :success
      end

      should "be able to upload genotypes" do
        Resque.expects(:enqueue).with(Preparsing, is_a(Fixnum))
        genotype_file_upload = ActionDispatch::Http::UploadedFile.new(
          filename: '23andme.txt', content_type: 'text/plain',
          tempfile: File.new("#{Rails.root}/test/data/23andMe_test.csv"))
        assert_difference 'UserAchievement.count' do
          put :create, commit: "Upload", genotype:
            { genotype: genotype_file_upload, filetype: "23andme"}
        end
        assert_redirected_to user_path(@user)
        assert_equal @publishing_award.id, UserAchievement.last.achievement_id
      end
    end
  end
end
