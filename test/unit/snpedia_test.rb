require_relative '../test_helper'

class SnpediaTest < ActiveSupport::TestCase
  setup do
    stub_solr
    @snp = FactoryGirl.create(:snp, name: 'rs12979860',
                              snpedia_updated: 32.days.ago)
  end

  should 'create SnpediaPapers' do
    VCR.use_cassette('snpedia_worker') do
      assert_difference(-> { SnpediaPaper.count }, 3) do
        Snpedia.new.perform(@snp.id)
      end
    end
    @snp.reload
    assert_equal 15, @snp.reload.ranking
    SnpediaPaper.find_each do |sp|
      assert_match '% of such hepatitis C patients respond to treatment', sp.summary
    end
  end

  should 'ignore snps not in the list' do
    @snp.update_attribute(:name, 'xxx')
    Snpedia.new.perform(@snp.id)
  end

  should 'skip existing papers' do
    FactoryGirl.create(:snpedia_paper,
                       revision: 445428,
                       url: "http://www.snpedia.com/index.php/Rs12979860(C;C)",
                       snps: [@snp])
    VCR.use_cassette('snpedia_worker') do
      assert_difference(-> { SnpediaPaper.count }, 2) do
        Snpedia.new.perform(@snp.id)
      end
    end
    @snp.reload
    assert_equal 15, @snp.reload.ranking
  end

  should 'put a placeholder text into the summary if there is none' do
    MediaWiki::Gateway.any_instance.stubs(:get).returns('')
    VCR.use_cassette('snpedia_worker') do
      Snpedia.new.perform(@snp.id)
    end
    SnpediaPaper.find_each do |sp|
      assert_equal "No summary provided.", sp.summary
    end
  end

  should 'skip links that are redirects' do
    MediaWiki::Gateway.any_instance.stubs(:get).returns('#REDIRECT')
    VCR.use_cassette('snpedia_worker') do
      assert_no_difference(-> { SnpediaPaper.count }) do
        Snpedia.new.perform(@snp.id)
      end
    end
  end
end
