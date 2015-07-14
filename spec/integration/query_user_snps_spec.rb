RSpec.describe 'Querying of and through UserSnps' do
  let!(:snp) { create(:snp, name: 'rs123') }
  let!(:genotype) { create(:genotype) }
  let!(:user_snp) { UserSnp.new(snp, genotype, 'AC').save }

  it 'can query Genotypes by snp_name' do
    expect(Genotype.by_snp_name(snp.name)).to eq([genotype])
  end

  it 'can query Snps from Genotypes' do
    expect(genotype.snps).to eq([snp])
  end

  it 'can query Genotypes from Snps' do
    expect(snp.genotypes).to eq([genotype])
  end
end
