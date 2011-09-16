require_relative '../test_helper'

class SnpTest < ActiveSupport::TestCase
  context "Snp" do
    setup do
      Sunspot.stubs(:index)
      @snp = Factory(:snp)
    end

    context "papers" do
      should "be updated whan older than 31 days" do
        @snp.mendeley_updated = @snp.snpedia_updated = @snp.plos_updated = 32.days.ago
        @snp.save
        queue = sequence('queue')
        Resque.expects(:enqueue).with(Mendeley, @snp.id).in_sequence(queue)
        Resque.expects(:enqueue).with(Snpedia,  @snp.id).in_sequence(queue)
        Resque.expects(:enqueue).with(Plos,     @snp.id).in_sequence(queue)
        Snp.update_papers
      end

      should "not be updated when not older than 31 days" do
        @snp.mendeley_updated = @snp.snpedia_updated = @snp.plos_updated = 30.days.ago
        @snp.save
        Resque.expects(:enqueue).never
        Snp.update_papers
      end
    end
  end
end
