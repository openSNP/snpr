# encoding: utf-8
# frozen_string_literal: true
require_relative '../test_helper'

class SnpsControllerTest < ActionController::TestCase
  context "Snps" do
    setup do
      activate_authlogic
      Sidekiq::Client.stubs(:enqueue)
      @user = FactoryBot.create(:user)
      @snp = FactoryBot.create(:snp)
      @snp_comment = FactoryBot.create(:snp_comment, snp: @snp, user: @user)
      @user_snp = FactoryBot.create(:user_snp, snp: @snp, user: @user)
      @controller.send(:reset_session)
    end

    should "be shown" do
      FactoryBot.create(:mendeley_paper, snps: [@snp])
      FactoryBot.create(:plos_paper, snps: [@snp])
      FactoryBot.create(:snpedia_paper, snps: [@snp])
      FactoryBot.create(:genome_gov_paper, snps: [@snp])
      get(:show, id: @snp.name)
      assert_response :success
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
