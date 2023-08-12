# encoding: utf-8
# frozen_string_literal: true
require_relative '../test_helper'
# let's see how my testing skills go…
class BeaconControllerTest < ActionController::TestCase
  context 'Beacon' do
    setup do
      activate_authlogic
      @user = FactoryBot.create(:user)
      @snp = FactoryBot.create(:snp)
      @snp.allele_frequency['A'] = 2
      @snp.save
      @controller.send(:reset_session)
    end

    should 'be YES' do
      get(
        :responses,
        params: {
          pos: @snp.position,
          chrom: @snp.chromosome,
          allele: "A"
        }
      )

      assert_equal('YES', response.body)
    end

    should 'be NO' do
      get(
        :responses,
        params: {
          pos: @snp.position,
          chrom: @snp.chromosome,
          allele: "C"
        }
      )

      assert_equal('NO', response.body)
    end

    should 'be NONE' do
      get(
        :responses,
        params: {
          pos: @snp.position,
          chrom: @snp.chromosome
        }
      )

      assert_equal('NONE', response.body)
    end
  end
end
