RSpec.describe 'Genotype deletion' do
  let!(:snp) { create(:snp) }
  let!(:genotype) { create(:genotype) }
  let!(:user_snp) { UserSnp.new(snp, genotype).save }

  it 'removes all references from Snps' do
    expect(snp.genotype_ids).to include(genotype.id)
    genotype.destroy
    expect(snp.genotype_ids).to_not include(genotype.id)
  end
end
