RSpec.describe '/snps/rs123.json' do
  let!(:user) { create(:user, id: 23, name: 'Britney Spears') }
  let!(:genotype) { create(:genotype, id: 42, user: user) }
  let!(:snp) { create(:snp, name: 'rs123', chromosome: 7, position: 24_926_827) }
  let!(:user_snp) { UserSnp.new(snp, genotype, 'AC').save }

  it 'returns SNP data' do
    get '/snps/rs123.json'

    expect(JSON.parse(response.body)).to eq([
      {
        'snp' => {
          'name' =>  'rs123',
          'chromosome' =>  '7',
          'position' =>  '24926827',
        },
        'user' => {
          'name' => 'Britney Spears',
          'id' => 23,
          'genotypes' => [{ 'genotype_id' => 42, 'local_genotype' => 'AC' }],
        }
      }
    ])
  end
end
