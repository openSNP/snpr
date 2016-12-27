# frozen_string_literal: true
RSpec.describe Phenotype do
  let!(:phenotype) { create(:phenotype) }
  subject { phenotype.number_of_users }

  context 'with users' do
    before do
      create(:user_phenotype, phenotype: phenotype)
      create(:user_phenotype, phenotype: phenotype)
      create(:user_phenotype, phenotype: phenotype)
    end

    context 'without number_of_users_column' do
      it 'returns the number of users' do
        expect(phenotype.number_of_users).to eq(3)
      end
    end

    context 'with number_of_users_column' do
      it 'returns the number of users' do
        expect(described_class.with_number_of_users.first.number_of_users).to eq(3)
      end
    end
  end

  context 'without users' do
    context 'without number_of_users_column' do
      it 'returns the number of users' do
        expect(phenotype.number_of_users).to eq(0)
      end
    end

    context 'with number_of_users_column' do
      it 'returns 0' do
        expect(described_class.with_number_of_users.first.number_of_users).to eq(0)
      end
    end
  end
end
