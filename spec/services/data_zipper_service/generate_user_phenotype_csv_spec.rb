# frozen_string_literal: true

RSpec.describe DataZipperService::GenerateUserPhenotypeCsv do
  subject(:service) { described_class.new }

  # There needs to be at least one phenotype in the database for the CROSSTAB
  # query to work.
  let!(:phenotype_1) { create(:phenotype, characteristic: "hitchhiker's thumb") }
  let!(:phenotype_2) { create(:phenotype, characteristic: 'number of eyes') }

  let(:result) { service.call }
  let(:parsed_result) do
    CSV.parse(
      result.to_a.join,
      col_sep: ';',
      headers: :first_row
    )
  end

  it 'returns an Enumerator' do
    expect(result).to be_a(Enumerator)
  end

  it 'returns something, that passes as CSV' do
    expect(parsed_result).to be_a(CSV::Table)
  end

  it 'includes a header in the CSV' do
    expect(parsed_result.headers).to match(
      %w[
        user_id
        genotype_filename
        date_of_birth
        chrom_sex
        openhumans_name
      ] + Array.new(Phenotype.count) { an_instance_of(String) }
    )
  end

  it 'includes all phenotype characteristics as columns' do
    expect(parsed_result.headers)
      .to include("hitchhiker's thumb", 'number of eyes')
  end

  context 'for users without genotypes' do
    let!(:user) { create(:user) }
    let!(:user_phenotype) do
      create(:user_phenotype, user: user, phenotype: phenotype_1, variation: 'yes')
    end

    it 'does not include their phenotypes in the CSV' do
      expect(parsed_result['user_id']).not_to include(user.id.to_s)
    end
  end

  context 'for users with genotypes' do
    let!(:user_1) { create(:user, sex: 'why not', yearofbirth: 1990) }
    let!(:user_2) { create(:user, sex: 'female', yearofbirth: 1970) }

    let!(:genotype_1) { create(:genotype, user: user_1) }
    let!(:genotype_2) { create(:genotype, user: user_2) }
    let!(:genotype_3) { create(:genotype, user: user_2) }

    let!(:user_phenotype_1) do
      create(
        :user_phenotype,
        phenotype: phenotype_1,
        variation: 'yes',
        user: user_1
      )
    end
    let!(:user_phenotype_2) do
      create(
        :user_phenotype,
        phenotype: phenotype_1,
        variation: 'no',
        user: user_2
      )
    end
    let!(:user_phenotype_3) do
      create(
        :user_phenotype,
        phenotype: phenotype_2,
        variation: '27',
        user: user_1
      )
    end

    it 'returns a row per genotype' do
      expect(parsed_result.to_a.size).to eq(4)
      expect(parsed_result.to_a[1..-1]).to eq(
        [
          [
            user_1.id.to_s,
            "#{user_1.id}.23andme.#{genotype_1.id}",
            '1990',
            'why not',
            '-',
            'yes',
            '27'
          ],
          [
            user_2.id.to_s,
            "#{user_2.id}.23andme.#{genotype_2.id}",
            '1970',
            'female',
            '-',
            'no',
            '-'
          ],
          [
            user_2.id.to_s,
            "#{user_2.id}.23andme.#{genotype_3.id}",
            '1970',
            'female',
            '-',
            'no',
            '-'
          ]
        ]
      )
    end
  end

  context 'when a phenotype characteristic contains a double quote' do
    let!(:genotype) { create(:genotype, user: user) }
    let!(:user) { create(:user) }
    let!(:phenotype) { create(:phenotype, characteristic: 'prefers " over \'') }
    let!(:user_phenotype) do
      create(:user_phenotype, phenotype: phenotype, variation: 'yes', user: user)
    end

    let(:result) do
      CSV.parse(
        service.call.to_a.join("\n"),
        col_sep: ';',
        headers: :first_row
      )
    end

    it 'does not fail' do
      expect(result.headers.last).to eq('prefers " over \'')
      expect(result.to_a.last.last).to eq('yes')
    end
  end
end
