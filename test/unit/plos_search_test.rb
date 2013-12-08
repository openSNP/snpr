require_relative '../test_helper'

class PlosSearchTest < ActiveSupport::TestCase
  context "worker" do
    setup do
      @snp = FactoryGirl.create(:snp)
    end

    should "associate new paper with snp" do
      response = File.read(Rails.root.join('test/data/plos_search_response.xml'))
      stub_request(:post, "api.plos.org/search").
        with(body: { 'api_key' => 'xxx', 'q' => @snp.name, 'rows' => '50', 'start' => '0' }).
        to_return(status: 200, body: response)
      PlosSearch.stubs(:api_key).returns('xxx')
      Sidekiq::Client.expects(:enqueue).with(PlosDetails, instance_of(Fixnum))
      assert_difference(-> { PlosPaper.count }) do
        PlosSearch.new.perform(@snp.id)
      end
      @snp.reload
      assert @snp.plos_updated
      plos_paper = PlosPaper.last
      assert_equal @snp, plos_paper.snp
      assert_equal 'Ester Aparicio', plos_paper.first_author
      assert_equal '10.1371/journal.pone.0013771', plos_paper.doi
      assert_equal DateTime.new(2010, 10, 29), plos_paper.pub_date
      assert_match 'rs8099917', plos_paper.title
    end
  end
end
