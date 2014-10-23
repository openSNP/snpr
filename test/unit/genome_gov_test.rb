require_relative '../test_helper'

class GenomeGovTest < ActiveSupport::TestCase
  setup do
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
    assert @snp.genome_gov_papers.include?(paper)
  end

  should 'update existing GenomeGovPapers' do
    paper = FactoryGirl.create(:genome_gov_paper,
      title: "Association of granulomatosis with polyangiitis (Wegener's) with HLA-DPB1*04 and SEMA6A gene variants: evidence from genome-wide analysis.",
      pubmed_link: 'http://www.ncbi.nlm.nih.gov/pubmed/23740775')
    paper.snps << @snp

    VCR.use_cassette('genome_gov_worker') do
      assert_no_difference(-> { GenomeGovPaper.count }) do
        GenomeGov.new.perform
      end
    end
    paper.reload
    assert_equal 'Xie G', paper.first_author
  end
end
