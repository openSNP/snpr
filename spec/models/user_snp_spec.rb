RSpec.describe UserSnp do
  let(:snp) { double(:snp, name: 'rs123') }
  let(:genotype) { double(:genotype, id: 1) }

  subject do
    UserSnp.new(snp, genotype)
  end

  describe '#local_genotype' do
    it "returns the local genotype of a user's SNP" do
      expect(ActiveRecord::Base).to receive(:sanitize).with('rs123')
        .and_return("'sanitized_rs123'")

      expect(Genotype).to receive(:unscoped).and_return(Genotype)
      expect(Genotype).to receive(:select).and_return(Genotype)
        .with("snps -> 'sanitized_rs123' AS local_genotype")
        .and_return(Genotype)
      expect(Genotype).to receive(:where).with(id: 1).and_return(Genotype)
      expect(Genotype).to receive(:first).and_return(Genotype)
      expect(Genotype).to receive(:local_genotype).and_return('AC')

      expect(subject.local_genotype).to eq('AC')
    end
  end
end
