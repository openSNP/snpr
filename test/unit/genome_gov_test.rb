require_relative '../test_helper'

class GenoveGovTest < ActiveSupport::TestCase
  setup do
    stub_solr
    @snp = FactoryGirl.create(:snp, name: 'rs9277554')
  end

  should 'create GenomeGovPapers' do
    VCR.use_cassette('genome_gov_worker') do
      assert_difference(-> { GenomeGovPaper.count }) do
        GenomeGov.new.perform
      end
    end
    paper = GenomeGovPaper.last
    assert paper.snps.include?(@snp)
    assert_equal 2.0e-50, paper.pvalue
    assert_equal 'pvalue description test', paper.pvalue_description
    assert_equal '[3.33-5.00] ', paper.confidence_interval
    assert_equal 'http://www.ncbi.nlm.nih.gov/pubmed/23740775', paper.pubmed_link
    assert_equal 'Xie G', paper.first_author
    assert_equal '09/01/2013', paper.pub_date
    assert_match /^Association of granulomatosis/, paper.title
    assert_equal 'Arthritis Rheum', paper.journal
    assert_equal "Wegener's granulomatosis", paper.trait
    @snp.reload
    assert_equal 2, @snp.ranking
  end
end
