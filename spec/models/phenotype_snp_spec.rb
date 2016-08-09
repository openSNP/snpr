RSpec.describe PhenotypeSnp do
  let(:snp) { FactoryGirl.create(:snp) }
  let(:phenotype) { FactoryGirl.create(:phenotype) }

  subject do
    PhenotypeSnp.create :snp_id => snp.id, :phenotype_id => phenotype.id
  end

  it 'has a unique (snp, phenotype) id pair' do
    subject.save!
    rel_a = PhenotypeSnp.new :snp_id => snp.id,
                             :phenotype_id => phenotype.id

    expect {rel_a.save!}.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it 'has a non-negative, not null score' do
    expect(subject.score).not_to be_nil
    expect(subject.score).to be >= 0
  end

  it 'validates the presence of snp id' do
    rel_a = PhenotypeSnp.create :snp_id => snp.id, :phenotype_id => 999

    expect(rel_a).not_to be_valid
    expect(rel_a.errors.messages[:phenotype]).to include("can't be blank")
  end

  it 'validates the presence of phenotype id' do
    rel_a = PhenotypeSnp.create :snp_id => 999, :phenotype_id => phenotype.id

    expect(rel_a).not_to be_valid
    expect(rel_a.errors.messages[:snp]).to include("can't be blank")
  end

end
