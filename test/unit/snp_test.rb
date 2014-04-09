require_relative '../test_helper'

class SnpTest < ActiveSupport::TestCase
  context "Snp" do
    setup do
      stub_solr
      @snp = FactoryGirl.create(:snp)
    end

    context "papers" do
      should "be updated when older than 31 days" do
        @snp.mendeley_updated = @snp.snpedia_updated = @snp.plos_updated = 32.days.ago
        @snp.save
        queue = sequence('queue')
        Sidekiq::Client.expects(:enqueue).with(Mendeley,   @snp.id).in_sequence(queue)
        Sidekiq::Client.expects(:enqueue).with(Snpedia,    @snp.id).in_sequence(queue)
        Sidekiq::Client.expects(:enqueue).with(PlosSearch, @snp.id).in_sequence(queue)
        Snp.update_papers
      end

      should "not be updated when not older than 31 days" do
        @snp.mendeley_updated = @snp.snpedia_updated = @snp.plos_updated = 30.days.ago
        @snp.save
        Sidekiq::Client.expects(:enqueue).never
        Snp.update_papers
      end
    end
  end
end
