# frozen_string_literal: true
# TODO: Add test cases for different filetypes.
describe Parsing do
  let(:genotype) do
    create(
      :genotype,
      genotype: File.open(File.absolute_path('test/data/23andMe_test.csv')),
      filetype: '23andme',
      parse_status: 'parsing'
    )
  end

  let(:emails) do
    ActionMailer::Base.deliveries
  end

  it 'parses a 23andme file' do
    described_class.new.perform(genotype.id)

    genotype.reload

    expect(genotype.user_snps.count).to eq(5)
    expect(
      genotype
      .user_snps
      .order(:snp_name)
      .pluck(:genotype_id, :snp_name, :local_genotype)
    ).to eq(
      [
        [genotype.id, 'rs11240777', 'AG'],
        [genotype.id, 'rs12124819', 'AG'],
        [genotype.id, 'rs3094315', 'AA'],
        [genotype.id, 'rs3131972', 'GG'],
        [genotype.id, 'rs4477212', 'AA']
      ]
    )
    expect(genotype.parse_status).to eq('done')

    expect(emails.count).to eq(1)
    expect(emails.first.subject).to eq('Finished parsing your genotyping')
  end

  it 'sets the parse status to "error" if parsing failed' do
    genotype.update!(genotype: StringIO.new('💥'))

    expect do
      described_class.new.perform(genotype.id)
    end.to raise_error(Parsing::ParseError, 'No data found in file')

    expect(genotype.reload.parse_status).to eq('error')
  end
end
