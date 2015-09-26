RSpec.describe 'Querying of and through UserSnps' do
  let!(:user) { create(:user) }
  let!(:snp) { create(:snp, name: 'rs123') }
  let!(:genotype) { create(:genotype, user: user) }
  let!(:user_snp) { UserSnp.new(snp, genotype, 'AC').save }

  it 'can query Snps from Genotypes' do
    expect(genotype.snps).to eq([snp])
  end

  it 'can query Genotypes from Snps' do
    expect(snp.genotypes).to eq([genotype])
  end

  it 'can include the local genotype in Genotypes' do
    expect(Genotype.with_local_genotype_for(snp).first.local_genotype).to eq('AC')
  end

  it 'can include the local genotype in Snps' do
    expect(Snp.with_local_genotype_for(genotype).first.local_genotype).to eq('AC')
  end

  it 'finds all Snps of a User' do
    expect(user.snps).to eq([snp])
  end
end
