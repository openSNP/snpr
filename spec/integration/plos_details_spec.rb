require 'spec_helper.rb'

describe PlosDetails, :vcr do
  let(:plos_paper) do
    create(:plos_paper, id: 1, reader: 0, doi: '10.1371/journal.pone.0089204')
  end

  it 'updates the view count' do
    subject.perform plos_paper.id
    expect(plos_paper.reload.reader).to eq(5047) # that's a lot of openSNP readers!
  end
end
