require 'spec_helper.rb'

describe PlosDetails do
  let(:plos_paper) do
    create(:plos_paper, id: 1, reader: 0, doi: '10.1371/journal.pone.0089204')
  end
  let(:job) {PlosDetails.new}

  it 'updates the view count' do
    before = plos_paper.reader

    response = double('response', body: '{"views":23}')
    expect(Net::HTTP).to receive(:get_response).
        with(URI 'http://alm.plos.org/api/v3/articles/10.1371/journal.pone.0089204?api_key=foo').
        and_return(response)
    
    job.perform plos_paper.id
    expect(plos_paper.reader).to eq(23)
  end
end
