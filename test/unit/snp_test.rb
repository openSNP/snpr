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
