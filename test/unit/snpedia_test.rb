# frozen_string_literal: true
require_relative '../test_helper'

class SnpediaTest < ActiveSupport::TestCase
  setup do
    @snp = FactoryBot.create(:snp, name: 'rs12979860',
                              snpedia_updated: 32.days.ago)
  end

  should 'create SnpediaPapers' do
    VCR.use_cassette('SnpediaWorker create SnpediaPapers') do
      assert_difference(-> { SnpediaPaper.count }, 3) do
        Snpedia.new.perform(@snp.id)
      end
    end
    @snp.reload
    assert @snp.snpedia_updated
    assert_equal 15, @snp.ranking
    SnpediaPaper.find_each do |sp|
      assert_match '% of such hepatitis C patients respond to treatment', sp.summary
    end
  end

  should 'ignore snps not in the list' do
    @snp.update_attribute(:name, 'xxx')
    Snpedia.new.perform(@snp.id)
  end

  should 'skip existing papers' do
    paper = FactoryBot.create(
      :snpedia_paper,
      revision: 445428,
      url: "http://www.snpedia.com/index.php/Rs12979860(C;C)",
    )
    paper.update!(snps: [@snp])
    VCR.use_cassette('SnpediaWorker skip existing papers') do
      assert_difference(-> { SnpediaPaper.count }, 2) do
        Snpedia.new.perform(@snp.id)
      end
    end
    @snp.reload
    assert_equal 15, @snp.ranking
  end

  should 'put a placeholder text into the summary if there is none' do
    MediaWiki::Gateway.any_instance.stubs(:get).returns('')
    VCR.use_cassette('SnpediaWorker put a placeholder text into the summary if there is none') do
      Snpedia.new.perform(@snp.id)
    end
    SnpediaPaper.find_each do |sp|
      assert_equal "No summary provided.", sp.summary
    end
  end

  should 'skip links that are redirects' do
    MediaWiki::Gateway.any_instance.stubs(:get).returns('#REDIRECT')
    VCR.use_cassette('SnpediaWorker skip links that are redirects') do
      assert_no_difference(-> { SnpediaPaper.count }) do
        Snpedia.new.perform(@snp.id)
      end
    end
  end
end
