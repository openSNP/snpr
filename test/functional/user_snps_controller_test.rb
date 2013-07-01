# encoding: utf-8
require_relative '../test_helper'

class UserSnpsControllerTest < ActionController::TestCase
  context "UserSnps" do
    setup do
      @snp = FactoryGirl.create(:snp)
      @user_snp = FactoryGirl.create(:user_snp, snp: @snp)
    end

    should "show up on index" do
      get :index, local_genotype: 'AG', snp_name: @snp.name
      assert_response :success
      assert_equal [@user_snp], assigns(:user_snps)
      assert_equal 'AG', assigns(:local_genotype)
    end
  end
end
