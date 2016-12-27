# frozen_string_literal: true
require_relative '../test_helper'

class SnpTest < ActiveSupport::TestCase
  context "Snp" do
    setup do
      @snp = FactoryGirl.create(:snp)
    end

    should 'sum up genotype frequencies' do
      @snp.update_attribute(
        :genotype_frequency,
        { "GT" => 1, "GG" => 2, "TT" => 3, "AC" => 4, "00" => 5 }
      )
      assert_equal 15, @snp.total_genotypes
    end

    should 'sum up allele frequencies' do
      @snp.update_attribute(
        :allele_frequency,
        { "A" => 1, "T" => 2, "G" => 3, "C" => 4 }
      )
      assert_equal 10, @snp.total_alleles
    end
  end
end
