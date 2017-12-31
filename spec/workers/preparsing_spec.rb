RSpec.describe Preparsing do
  let(:genotype) do
    create(
      :genotype,
      genotype: File.open(File.absolute_path('test/data/23andMe_test.csv')),
      filetype: '23andme',
      parse_status: 'queued'
    )
  end

  it "updates the genotype's parse status" do
    described_class.new.perform(genotype.id)

    expect(genotype.reload.parse_status).to eq('parsing')
  end
end
