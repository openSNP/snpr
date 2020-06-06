# frozen_string_literal: true

RSpec.describe ZipGenotypingFiles do
  subject(:worker) { described_class.new }

  let!(:tentacle) { create(:phenotype, characteristic: 'tentacle') }

  context 'when there are genotypes found' do
    # User with matching phenotype and variant
    let!(:user_1) { create(:user) }
    let!(:genotype_1) do
      create(:genotype, user: user_1, genotype: genotype_file_1)
    end
    let(:genotype_file_1) do
      StringIO.new('user 1 genotype')
    end
    let!(:user_phenotype_1) do
      create(
        :user_phenotype,
        user: user_1,
        phenotype: tentacle,
        variation: 'purple'
      )
    end

    # Second user with matching phenotype and variant
    let!(:user_2) { create(:user) }
    let!(:genotype_2) do
      create(:genotype, user: user_2, genotype: genotype_file_2)
    end
    let(:genotype_file_2) do
      StringIO.new('user 2 genotype')
    end
    let!(:user_phenotype_2) do
      create(
        :user_phenotype,
        user: user_2,
        phenotype: tentacle,
        variation: 'also purple'
      )
    end

    # User with other variant
    let!(:user_3) { create(:user) }
    let!(:genotype_3) do
      create(:genotype, user: user_3, genotype: genotype_file_3)
    end
    let(:genotype_file_3) do
      StringIO.new('user 3 genotype')
    end
    let!(:user_phenotype_3) do
      create(
        :user_phenotype,
        user: user_3,
        phenotype: tentacle,
        variation: 'green'
      )
    end

    let!(:slime) { create(:phenotype, characteristic: 'slime') }

    # User with other phenotype
    let!(:user_4) { create(:user) }
    let!(:genotype_4) do
      create(:genotype, user: user_4, genotype: genotype_file_4)
    end
    let(:genotype_file_4) do
      StringIO.new('user 4 genotype')
    end
    let!(:user_phenotype_4) do
      create(
        :user_phenotype,
        user: user_4,
        phenotype: slime,
        variation: 'purple'
      )
    end

    it 'zips genotyping files' do
      worker.perform(
        tentacle.id,
        user_phenotype_1.variation,
        'user@example.com'
      )

      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject)
        .to eq('openSNP.org: The data you requested is ready to be downloaded')

      file = mail.text_part.decoded[%r{data/zip/.*?\.zip}]

      Zip::File.open(Rails.root.join('public', file)) do |zip_file|
        expect(zip_file.entries.count).to eq(2)
        expect(zip_file.glob("user#{user_1.id}_*.txt").first.get_input_stream.read)
          .to eq(File.read(genotype_1.genotype.path))
        expect(zip_file.glob("user#{user_2.id}_*.txt").first.get_input_stream.read)
          .to eq(File.read(genotype_2.genotype.path))
      end
    end
  end

  context 'when there are no genotypes found' do
    it 'tells the user' do
      worker.perform(
        tentacle.id,
        'blue',
        'user@example.com'
      )

      expect(ActionMailer::Base.deliveries.last.subject)
        .to eq('openSNP.org: No genotyping files match your search')
    end
  end
end
