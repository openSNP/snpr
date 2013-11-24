# encoding: utf-8
require_relative '../test_helper'

class SnpsControllerTest < ActionController::TestCase
  context "Snps" do
    setup do
      stub_solr
      activate_authlogic
      Sidekiq::Client.stubs(:enqueue)
      @user = FactoryGirl.create(:user)
      @snp = FactoryGirl.create(:snp)
      @snp_comment = FactoryGirl.create(:snp_comment, snp: @snp, user: @user)
      @user_snp = FactoryGirl.create(:user_snp, snp: @snp, user: @user)
      @controller.send(:reset_session)
    end

    should "be shown" do
      get(:show, id: @snp.name)
    end

    context "when logged-in" do
      setup do
        @controller.stubs(:current_user).returns(@user)
        assert_equal @user, @controller.send(:current_user)
      end

      should "be shown" do
        get(:show, id: @snp.name)
      end
    end
  end
end
