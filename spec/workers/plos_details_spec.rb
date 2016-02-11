describe PlosDetails do
  let(:plos_paper) do
    create(:plos_paper, id: 1, reader: 0, doi: '10.1371/journal.pone.0089204')
  end
  let(:job) {PlosDetails.new}

  it 'updates the view count' do
    before = plos_paper.reader
    job.perform plos_paper.id
    expect(plos_paper.reader).not_to eq(before)
  end
end
