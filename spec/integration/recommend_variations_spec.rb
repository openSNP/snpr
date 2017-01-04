# frozen_string_literal: true
RSpec.describe 'Recommend variations' do
  subject do
    RecommenderWorker.new.perform('VariationRecommender')
  end

  let!(:phenotype1) { create(:phenotype) }
  let!(:phenotype2) { create(:phenotype) }
  let!(:phenotype3) { create(:phenotype) }
  let!(:user1) { create(:user) }
  let!(:user2) { create(:user) }
  let!(:user_phenotype1) do
    create(:user_phenotype, user: user1, phenotype: phenotype1, variation: 'foo')
  end
  let!(:user_phenotype2) do 
    create(:user_phenotype, user: user1, phenotype: phenotype2, variation: 'bar')
  end
  let!(:user_phenotype2) do
    create(:user_phenotype, user: user1, phenotype: phenotype3, variation: 'baz')
  end
  let!(:user_phenotype3) do
    create(:user_phenotype, user: user2, phenotype: phenotype2, variation: 'bar')
  end
  let!(:user_phenotype4) do
    create(:user_phenotype, user: user2, phenotype: phenotype3, variation: 'ping')
  end

  it 'recommends variations' do
    subject

    recommendations = VariationRecommender.new.for("#{phenotype2.id}=>bar")
    expect(recommendations.map(&:item_id)).to eq(["#{phenotype3.id}=>ping"])
  end
end
