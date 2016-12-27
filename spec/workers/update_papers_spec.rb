# frozen_string_literal: true
RSpec.describe UpdatePapers do
  around { |e| Timecop.freeze(Time.current.beginning_of_minute, &e) }

  let(:mendeley_snp_ids) { [1, 2, 3] }
  let(:plos_snp_ids) { [4, 5, 6] }
  let(:snpedia_snp_ids) { [7, 8, 9] }

  it 'updates papers that have not been updated for MAX_AGE days' do
    expect(Snp).to receive(:where).with('mendeley_updated < ?', 31.days.ago).and_return(Snp)
    expect(Snp).to receive(:pluck).with(:id).and_return(mendeley_snp_ids)

    expect(Snp).to receive(:where).with('plos_updated < ?', 31.days.ago).and_return(Snp)
    expect(Snp).to receive(:pluck).with(:id).and_return(plos_snp_ids)

    expect(Snp).to receive(:where).with('snpedia_updated < ?', 31.days.ago).and_return(Snp)
    expect(Snp).to receive(:pluck).with(:id).and_return(snpedia_snp_ids)

    expect(MendeleySearch).to receive(:perform_async).with(1)
    expect(MendeleySearch).to receive(:perform_async).with(2)
    expect(MendeleySearch).to receive(:perform_async).with(3)

    expect(PlosSearch).to receive(:perform_async).with(4)
    expect(PlosSearch).to receive(:perform_async).with(5)
    expect(PlosSearch).to receive(:perform_async).with(6)

    expect(Snpedia).to receive(:perform_async).with(7)
    expect(Snpedia).to receive(:perform_async).with(8)
    expect(Snpedia).to receive(:perform_async).with(9)

    subject.perform
  end
end
