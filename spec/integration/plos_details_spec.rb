require 'spec_helper.rb'

describe PlosDetails, :vcr do
  let(:plos_paper) do
    create(:plos_paper, id: 1, reader: 0, doi: '10.1371/journal.pone.0089204')
  end
  let(:job) {PlosDetails.new}

  it 'updates the view count' do
    before = plos_paper.reader

    VCR.use_cassette 'plos_detail' do
      job.perform plos_paper.id
    end
    expect(plos_paper.reload.reader).not_to eq(before)
    expect(plos_paper.reload.reader).to eq(5047) # that's a lot of openSNP readers!
  end
end
