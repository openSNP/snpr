require_relative '../test_helper'

class ReferenceTest < ActiveSupport::TestCase
  context "Reference" do
    setup do
      @snps = FactoryGirl.create_list(:snp, 2)
      @mendeley_paper = FactoryGirl.create(:mendeley_paper)
      @plos_paper = FactoryGirl.create(:plos_paper)
    end

    should "associate snps and papers" do
      @mendeley_paper.snps = @snps
      @plos_paper.snps = @snps
      assert_equal [@mendeley_paper, @plos_paper], @snps.first.papers
    end
  end
end
