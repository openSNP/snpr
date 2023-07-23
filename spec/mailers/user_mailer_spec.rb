# frozen_string_literal: true
describe UserMailer do
  let(:user) { double(:user, name: 'Lord Schmorgoroth', email: 'ls@example.com') }
  let(:genotype) { double('genotype', id: 1, user: user, filetype: '23andme') }
  let(:stats) { { rows_without_comments: 2, rows_after_parsing: 1 } }

  describe '#finished_parsing' do
    it 'notifies the user about his genotype having been parsed' do
      expect(Genotype).to receive(:find).with(genotype.id).and_return(genotype)
      perform_enqueued_jobs do
        described_class.finished_parsing(genotype.id, stats).deliver_later
      end
      mail = ActionMailer::Base.deliveries.last
      mail.parts.each do |p|
        expect(p.body.raw_source).to include(user.name)
        expect(p.body.raw_source).to include('23andMe')
      end
    end
  end
end
