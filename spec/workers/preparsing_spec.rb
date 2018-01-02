RSpec.describe Preparsing do
  context 'when the genotype is valid' do
    let(:genotype) do
      create(
        :genotype,
        genotype: File.open(File.absolute_path('test/data/23andMe_test.csv')),
        filetype: '23andme',
        parse_status: 'queued'
      )
    end

    it "updates the genotype's parse status" do
      described_class.new.perform(genotype.id)

      expect(genotype.reload.parse_status).to eq('parsing')
    end
  end

  context 'when the genotype file is faulty' do
    let(:genotype) do
      create(:genotype, genotype: StringIO.new('XXX'))
    end

    it "updates the genotype's parse status" do
      described_class.new.perform(genotype.id)

      expect(genotype.reload.parse_status).to eq('error')
    end
  end

  context 'when the worker raises an error' do
    let(:genotype) do
      create(:genotype)
    end

    before do
      expect(File).to receive(:open).and_raise('Meh.')
    end

    it "updates the genotype's parse status" do
      expect do
        described_class.new.perform(genotype.id)
      end.to raise_error('Meh.')

      expect(genotype.reload.parse_status).to eq('error')
    end
  end
end
