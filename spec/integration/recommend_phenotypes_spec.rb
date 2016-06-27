RSpec.describe 'Recommend phenotypes' do
  subject do
    RecommenderWorker.new.perform('PhenotypeRecommender')
  end

  let!(:phenotype1) { create(:phenotype) }
  let!(:phenotype2) { create(:phenotype) }
  let!(:phenotype3) { create(:phenotype) }
  let!(:user1) { create(:user) }
  let!(:user2) { create(:user) }
  let!(:user_phenotype1) { create(:user_phenotype, user: user1, phenotype: phenotype1) }
  let!(:user_phenotype2) { create(:user_phenotype, user: user1, phenotype: phenotype2) }
  let!(:user_phenotype2) { create(:user_phenotype, user: user1, phenotype: phenotype3) }
  let!(:user_phenotype3) { create(:user_phenotype, user: user2, phenotype: phenotype1) }
  let!(:user_phenotype4) { create(:user_phenotype, user: user2, phenotype: phenotype3) }

  it 'recommends phenotypes' do
    subject

    recommendations = PhenotypeRecommender.new.for(phenotype1.id)
    expect(recommendations.map(&:item_id).map(&:to_i)).to eq([phenotype3.id])
  end
end
