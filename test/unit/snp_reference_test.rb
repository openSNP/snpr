# frozen_string_literal: true
require_relative '../test_helper'

class SnpReferenceTest < ActiveSupport::TestCase
  context "SnpReference" do
    setup do
      @snps = FactoryGirl.create_list(:snp, 2)
    end

    %w(mendeley plos snpedia genome_gov).each do |paper|
      should "associate snps with #{paper} papers" do
        @paper = FactoryGirl.create("#{paper}_paper".to_sym)

        assert_difference(lambda { SnpReference.count }) do
          @paper.snps << @snps.first
        end
        assert_equal [@paper], @snps.first.send(:"#{paper}_papers")
        assert_equal [@snps.first], @paper.snps
      end
    end
  end
end
