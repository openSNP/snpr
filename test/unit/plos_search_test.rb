require_relative '../test_helper'

class PlosSearchTest < ActiveSupport::TestCase
  setup do
    @snp = FactoryGirl.create(:snp)
  end

  should "create new PlosPapers for results from PLOS API" do
    response = File.read(Rails.root.join('test/data/plos_search_response.xml'))
    stub_request(:post, "api.plos.org/search").
      with(body: { 'api_key' => 'xxx', 'q' => @snp.name, 'rows' => '999', 'start' => '0' }).
      to_return(status: 200, body: response)
    PlosSearch.stubs(:api_key).returns('xxx')
    Sidekiq::Client.expects(:enqueue).with(PlosDetails, instance_of(Fixnum))
    assert_difference(-> { PlosPaper.count }) do
      PlosSearch.new.perform(@snp.id)
    end
    @snp.reload
    assert @snp.plos_updated
    plos_paper = PlosPaper.last
    assert plos_paper.snps.include?(@snp)
    assert_equal 'Ester Aparicio', plos_paper.first_author
    assert_equal '10.1371/journal.pone.0013771', plos_paper.doi
    assert_equal DateTime.new(2010, 10, 29), plos_paper.pub_date
    assert_match 'rs8099917', plos_paper.title
  end

  should "update existing PlosPapers" do
    plos_paper = FactoryGirl.create(:plos_paper, doi: 'x')
    article = mock(
      authors:      ['Max Mustermann'],
      id:           'x',
      published_at: DateTime.new(2013, 12, 8),
      title:        'Musterartikel',
    )
    worker = PlosSearch.new
    worker.instance_variable_set(:@snp, @snp)
    Sidekiq::Client.expects(:enqueue).with(PlosDetails, plos_paper.id)
    worker.import_article(article)
    plos_paper.reload
    assert_equal 'Musterartikel', plos_paper.title
    assert_equal 'x', plos_paper.doi
    assert_equal DateTime.new(2013, 12, 8), plos_paper.pub_date
    assert_equal 'Max Mustermann', plos_paper.first_author
  end

  should 'skip search for "illegal" snps' do
    worker = PlosSearch.new
    @snp.update_attribute(:name, 'mt-xxx')
    worker.instance_variable_set(:@snp, @snp)
    PlosSearch.new.perform(@snp.id)
  end

  should "skip search if snp's plos papers where recently updated" do
    worker = PlosSearch.new
    @snp.update_attribute(:plos_updated, 30.days.ago)
    worker.instance_variable_set(:@snp, @snp)
    PlosSearch.new.perform(@snp.id)
  end

  should "not break when there are no authors" do
    article = mock(
      authors:      nil,
      id:           'x',
      published_at: DateTime.new(2013, 12, 8),
      title:        'Musterartikel',
    )
    worker = PlosSearch.new
    worker.instance_variable_set(:@snp, @snp)
    Sidekiq::Client.stubs(:enqueue)
    assert_difference(-> { PlosPaper.count }) do
      worker.import_article(article)
    end
    plos_paper = PlosPaper.last
    assert_nil plos_paper.first_author
  end
end
