RSpec.describe 'DAS' do
  let!(:user) { create(:user, id: 23, name: 'Britney Spears') }
  let!(:genotype) { create(:genotype, id: 42, user: user) }
  let!(:snp) { create(:snp, name: 'rs123', chromosome: 7, position: 24926827) }
  let!(:user_snp) { UserSnp.new(snp, genotype, 'AC').save }

  it 'returns DAS data' do
    get '/das/23/features', { segment: '7:0,24926827', type: 'AC' },
                            { 'server-software' => 'Foo 1.0' }

    expect(response.headers['X-DAS-Status']).to eq('200')
    xml = Nokogiri::XML.parse(response.body)
    expect(xml.xpath('/DASGFF/GFF/SEGMENT/FEATURE').attr('id').to_s).to eq('rs123')
    expect(xml.xpath('/DASGFF/GFF/SEGMENT/FEATURE/TYPE').attr('id').to_s).to eq('AC')
    expect(xml.xpath('/DASGFF/GFF/SEGMENT/FEATURE/METHOD').attr('id').to_s).to eq('')
    expect(xml.xpath('/DASGFF/GFF/SEGMENT/FEATURE/START').text.strip).to eq('24926827')
    expect(xml.xpath('/DASGFF/GFF/SEGMENT/FEATURE/END').text.strip).to eq('24926827')
    expect(xml.xpath('/DASGFF/GFF/SEGMENT/FEATURE/LINK').text.strip)
      .to eq('http://www.example.com/snps/rs123')
    expect(xml.xpath('/DASGFF/GFF/SEGMENT/FEATURE/LINK').attr('href').to_s)
      .to eq('http://www.example.com/snps/rs123')
  end
end
