require_relative '../test_helper'

class ReferenceTest < ActiveSupport::TestCase
  context "Reference" do
    setup do
      stub_solr
      @snps = FactoryGirl.create_list(:snp, 2)
      @mendeley_paper = FactoryGirl.create(:mendeley_paper)
      @plos_paper = FactoryGirl.create(:plos_paper)
    end

    should "associate snps with papers" do
      assert_difference(lambda { Reference.count }, 2) do
        @mendeley_paper.snps = @snps
      end
      assert_difference(lambda { Reference.count }, 2) do
        @plos_paper.snps = @snps
      end
      assert_equal [@mendeley_paper, @plos_paper], @snps.first.papers
    end
  end
end
