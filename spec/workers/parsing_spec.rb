describe Parsing do
  describe '#notify_user' do
    let(:mail) { double('mail') }
    let(:genotype) { double('genotype', id: 1) }
    let(:stats) { { foos: 7 } }

    it 'sends an email to the user' do
      subject.instance_variable_set(:@stats, stats)
      subject.instance_variable_set(:@genotype, genotype)
      expect(UserMailer).to receive(:delay).and_return(UserMailer)
      expect(UserMailer).to receive(:finished_parsing).with(genotype.id, stats)

      subject.notify_user
    end
  end
end
