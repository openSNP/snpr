module SolrHelper
  def stub_solr
    allow_any_instance_of(RSolr::Connection).to receive(:execute)
  end
end
